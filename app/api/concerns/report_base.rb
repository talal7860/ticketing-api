module ReportBase
  extend ActiveSupport::Concern
  included do
    helpers do

      def can_view_reports?
        unless current_user.can_view_reports?
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
