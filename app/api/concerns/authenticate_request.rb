require 'api_exception'

module AuthenticateRequest
  extend ActiveSupport::Concern

  included do
    helpers do
      # Devise methods overwrites
      def current_user
        return nil if request.headers['Authorization'].blank?
        @current_user ||= User.by_auth_token(request.headers['Authorization'])
      end
      # Authenticate request with token of user
      def authenticate_customer!
        raise unauthenticated_error! unless current_user && current_user.customer?
      end

      def authenticate_support_representative!
        raise unauthenticated_error! unless current_user && current_user.support_representative?
      end

      def authenticate_admin!
        raise unauthenticated_error! unless current_user && current_user.admin?
      end

      def authenticate_admin_and_customer!
        raise unauthenticated_error! unless current_user && %w(Admin Customer).include?(current_user.type)
      end

      def authenticate!
        raise unauthenticated_error! unless current_user
      end

      def unauthenticated_error!
        error!({meta: {code: RESPONSE_CODE[:unauthorized], message: I18n.t("errors.not_authenticated"), debug_info: ''}}, RESPONSE_CODE[:unauthorized])
      end

      def authenticate_request!
        if request.headers['AccessToken'].blank?
          raise error!({meta: {code: RESPONSE_CODE[:forbidden], message: I18n.t("errors.bad_request"), debug_info: ''}}, RESPONSE_CODE[:forbidden])
        end
      end
    end
  end
end
