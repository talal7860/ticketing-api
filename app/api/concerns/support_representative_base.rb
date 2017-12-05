module SupportRepresentativeBase
  extend ActiveSupport::Concern
  included do
    helpers do

      def get_support_representative_by_token(invitation_token)
        @support_representative = SupportRepresentative.find_by_invitation_token(invitation_token)
        unless @support_representative
          raise ApiException.new(
            http_status: RESPONSE_CODE[:not_found],
            code: RESPONSE_CODE[:not_found],
            message: I18n.t('errors.supportrepresentative.invalid_token')
          )
        end
      end

    end
  end
end

