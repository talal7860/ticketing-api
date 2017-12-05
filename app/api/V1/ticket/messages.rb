module V1
  module Ticket
    class Messages < Grape::API
      include V1Base
      include AuthenticateRequest
      include TicketBase
      include MessageBase

      VALID_PARAMS = %w(content)

      helpers do
        def message_params
          params.select{|key,value| VALID_PARAMS.include?(key.to_s)}
        end

        def message_with_user_params
          custom_params = message_params
          custom_params.merge!(sender_id: current_user.id) if current_user.present?
        end
      end

      namespace :tickets do
        route_param :ticket_id do
          resource :messages do

            desc 'Create new message', {
              consumes: [ "application/x-www-form-urlencoded" ],
              headers: HEADERS_DOCS,
              http_codes: [
                { code: 200, message: 'success' },
                { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' },
                { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
              ]
            }
            params do
              requires :content, type: String, desc: 'Content'
            end
            post do
              authenticate!
              can_post_message_to_ticket?(params[:ticket_id])
              params.merge!(sender_id: current_user.id) if @ticket.present?
              message = @ticket.messages.new(message_with_user_params)
              if message.save
                serialization = MessageSerializer.new(message)
                render_success(serialization.as_json)
              else
                error = message.errors.full_messages.join(', ')
                render_error(RESPONSE_CODE[:unprocessable_entity], error)
                return
              end
            end

            desc 'Get all messages', {
              consumes: [ "application/x-www-form-urlencoded" ],
              headers: HEADERS_DOCS,
              http_codes: [
                { code: 200, message: 'success' }
              ]
            }
            params do
              optional :page, type: Integer, desc: 'page'
              optional :per_page, type: Integer, desc: 'per_page'
            end
            get :all do
              authenticate!
              can_see_messages?(params[:ticket_id])
              get_ticket(params[:ticket_id]);
              page = (params[:page] || 1).to_i
              per_page = (params[:per_page] || PER_PAGE).to_i
              messages = @ticket.messages.order("created_at DESC").page(page).per(per_page)
              serialization = ActiveModel::Serializer::CollectionSerializer.new(messages, each_serializer: MessageSerializer)
              render_success(serialization.as_json , pagination_dict(messages))
            end

          end
        end
      end
    end
  end
end

