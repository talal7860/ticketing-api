module MessageBase
  extend ActiveSupport::Concern
  included do
    helpers do
      def get_message(id)
        @message = Message.find_by_id(id)

        unless @message
          raise ApiException.new(
            http_status: RESPONSE_CODE[:not_found],
            code: RESPONSE_CODE[:not_found],
            message: I18n.t('errors.message.not_found')
          )
        end
      end

      def can_post_message_to_ticket?(ticket_id)
        get_ticket(ticket_id)
        unless current_user.can_post_message_to_ticket?(@ticket)
          raise ApiException.new(
            http_status: RESPONSE_CODE[:forbidden],
            code: RESPONSE_CODE[:forbidden],
            message: I18n.t('errors.forbidden')
          )
        end
      end

      def can_see_messages?(ticket_id)
        get_ticket(ticket_id)
        unless current_user.can_see_messages_for_ticket?(@ticket)
          raise ApiException.new(
            http_status: RESPONSE_CODE[:forbidden],
            code: RESPONSE_CODE[:forbidden],
            message: I18n.t('errors.forbidden')
          )
        end
      end

      def can_resolve_message?(id)
        get_message(id)
        unless current_user.can_resolve_message?(@message)
          raise ApiException.new(
            http_status: RESPONSE_CODE[:forbidden],
            code: RESPONSE_CODE[:forbidden],
            message: I18n.t('errors.forbidden')
          )
        end
      end

    end
  end
end


