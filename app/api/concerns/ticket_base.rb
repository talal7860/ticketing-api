module TicketBase
  extend ActiveSupport::Concern
  included do
    helpers do
      def get_ticket(id)
        @ticket = Ticket.find_by_id(id)

        unless @ticket
          raise ApiException.new(
            http_status: RESPONSE_CODE[:not_found],
            code: RESPONSE_CODE[:not_found],
            message: I18n.t('errors.ticket.not_found')
          )
        end
      end

      def can_manage_ticket?(id)
        get_ticket(id)
        unless current_user.can_manage_ticket?(@ticket)
          raise ApiException.new(
            http_status: RESPONSE_CODE[:forbidden],
            code: RESPONSE_CODE[:forbidden],
            message: I18n.t('errors.forbidden')
          )
        end
      end

      def can_delete_ticket?(id)
        get_ticket(id)
        unless current_user.can_delete_ticket?(@ticket)
          raise ApiException.new(
            http_status: RESPONSE_CODE[:forbidden],
            code: RESPONSE_CODE[:forbidden],
            message: I18n.t('errors.forbidden')
          )
        end
      end


      def can_work_on_ticket?(id)
        get_ticket(id)
        unless current_user.can_work_on_ticket?(@ticket)
          raise ApiException.new(
            http_status: RESPONSE_CODE[:forbidden],
            code: RESPONSE_CODE[:forbidden],
            message: I18n.t('errors.forbidden')
          )
        end
      end

      def can_resolve_ticket?(id)
        get_ticket(id)
        unless current_user.can_resolve_ticket?(@ticket)
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

