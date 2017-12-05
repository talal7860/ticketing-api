module V1
  module Ticket
    class Messages < Grape::API
      include V1Base
      include AuthenticateRequest

      VALID_PARAMS = %w(content)

      helpers do
        def message_params
          params.select{|key,value| VALID_PARAMS.include?(key.to_s)}
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
              requires :title, type: String, desc: 'Message Title'
              requires :description, type: String, desc: 'Message Description'
            end
            post do
              authenticate_user!
              message = current_user.messages.new(message_params)
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
              #headers: HEADERS_DOCS,
              http_codes: [
                { code: 200, message: 'success' }
              ]
            }
            params do
              optional :page, type: Integer, desc: 'page'
              optional :per_page, type: Integer, desc: 'per_page'
            end
            get :all_messages do
              #authenticate!
              page = (params[:page] || 1).to_i
              per_page = (params[:per_page] || PER_PAGE).to_i
              messages = Message.order("created_at DESC").page(page).per(per_page)
              serialization = ActiveModel::Serializer::CollectionSerializer.new(messages, each_serializer: MessageSerializer)
              render_success(serialization.as_json , pagination_dict(messages))
            end



          end
        end
      end

    end
  end
end

