module V1
  class Tickets < Grape::API
    include V1Base
    include AuthenticateRequest
    include TicketBase

    VALID_PARAMS = %w(title description owner_id)

    helpers do
      def ticket_params
        params.select{|key,value| VALID_PARAMS.include?(key.to_s)}
      end
    end

    resource :tickets do

      desc 'Get tickets', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
        http_codes: [
          { code: 200, message: 'success' },
          { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
        ]
      }
      params do
        optional :page, type: Integer, desc: 'page'
        optional :per_page, type: Integer, desc: 'per_page'
      end
      get :all do
        authenticate!
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || PER_PAGE).to_i
        tickets = current_user.tickets.order("status, created_at DESC").page(page).per(per_page)
        serialization = ActiveModel::Serializer::CollectionSerializer.new(tickets, each_serializer: TicketSerializer)
        render_success(serialization.as_json , pagination_dict(tickets))
      end

      desc 'Work on a ticket', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
        http_codes: [
          { code: 200, message: 'success' },
          { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') },
          { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
        ]
      }
      post ':id/work' do
        authenticate!
        can_work_on_ticket? params[:id]
        get_ticket params[:id]
        if @ticket.assign_support_representative(current_user)
          serialization = TicketSerializer.new(@ticket)
          status 200
          render_success(serialization.as_json)
        else
          error = @ticket.errors.full_messages.join(', ')
          render_error(RESPONSE_CODE[:unprocessable_entity], error)
        end
      end

      desc 'Resolve a ticket', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
        http_codes: [
          { code: 200, message: 'success' },
          { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') },
          { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
        ]
      }

      post ':id/resolve' do
        authenticate!
        can_resolve_ticket? params[:id]
        get_ticket params[:id]
        if @ticket.resolve
          serialization = TicketSerializer.new(@ticket)
          status 200
          render_success(serialization.as_json)
        else
          error = @ticket.errors.full_messages.join(', ')
          render_error(RESPONSE_CODE[:unprocessable_entity], error)
        end
      end

      desc 'Create new ticket', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
        http_codes: [
          { code: 201, message: 'success' },
          { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' },
          { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
        ]
      }
      params do
        requires :title, type: String, desc: 'Ticket Title'
        requires :description, type: String, desc: 'Ticket Description'
        optional :owner_id, type: String, desc: 'Owner ID (for Admin)'
      end
      post do
        authenticate_admin_and_customer!
        if current_user.admin?
          ticket = ::Ticket.new(ticket_params)
        else
          custom_params = ticket_params
          custom_params.delete(:owner_id)
          ticket = current_user.tickets.new(custom_params)
        end
        if ticket.save
          serialization = TicketSerializer.new(ticket)
          render_success(serialization.as_json)
        else
          error = ticket.errors.full_messages.join(', ')
          render_error(RESPONSE_CODE[:unprocessable_entity], error)
          return
        end
      end


      desc 'Get ticket', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
        http_codes: [
          { code: 200, message: 'success' },
          { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') },
          { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
        ]
      }
      get ':id' do
        authenticate!
        can_manage_ticket? params[:id]
        get_ticket params[:id]
        serialization = TicketSerializer.new(@ticket)
        render_success(serialization.as_json)
      end

      desc 'delete ticket', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
        http_codes: [
          { code: 200, message: 'success' },
          { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') },
          { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
        ]
      }
      delete ':id' do
        authenticate!
        can_delete_ticket? params[:id]
        get_ticket params[:id]
        @ticket.destroy
        render_success({ deleted: true })
      end
    end
  end
end
