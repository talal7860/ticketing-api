module V1
  class SupportRepresentatives < Grape::API
    include V1Base
    include AuthenticateRequest
    include SupportRepresentativeBase

    VALID_PARAMS = %w(first_name last_name email password password_confirmation invitation_token)

    helpers do
      def user_params
        params.select{|key,value| VALID_PARAMS.include?(key.to_s)}
      end
    end

    resource :support_representatives do

      desc 'Get Support Representatives', headers: HEADERS_DOCS, http_codes: [
        { code: 200, message: 'success' },
        { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
      ]
      params do
        optional :page, type: Integer, desc: 'page'
        optional :per_page, type: Integer, desc: 'per_page'
      end

      get :all do
        authenticate_admin!

        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || PER_PAGE).to_i
        support_representatives = SupportRepresentative.order("created_at DESC").page(page).per(per_page)

        serialization = ActiveModel::Serializer::CollectionSerializer.new(support_representatives, each_serializer: SupportRepresentative, show_token: false)

        render_success(serialization.as_json, pagination_dict(support_representatives))
      end

      desc 'Invite new Support Representative', {
        consumes: [ "application/x-www-form-urlencoded" ],
        headers: HEADERS_DOCS,
        http_codes: [
          { code: 201, message: 'success' },
          { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' }
        ]
      }
      params do
        requires :email, type: String, desc: 'Email'
        requires :first_name, type: String, desc: 'First Name'
        requires :last_name, type: String, desc: 'Last Name'
      end
      post :invite do
        authenticate_admin!
        sr = current_user.invite(user_params)
        if sr.errors.any?
          error = sr.errors.full_messages.join(', ')
          render_error(RESPONSE_CODE[:unprocessable_entity], error)
        else
          serialization = SupportRepresentativeSerializer.new(sr)
          render_success(serialization.as_json)
        end
      end


      desc 'Set Password for a Support Representative', {
        consumes: [ "application/x-www-form-urlencoded" ],
        http_codes: [
          { code: 200, message: 'success' },
          { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') },
          { code: RESPONSE_CODE[:unprocessable_entity], message: 'Validation error messages' }
        ]
      }
      params do
        requires :password, type: String, desc: 'Password'
        requires :password_confirmation, type: String, desc: 'Password Confirmation'
        requires :invitation_token, type: String, desc: 'Invitation Token'
      end

      post 'invitation/accept/:invitation_token' do
        get_support_representative_by_token(params[:invitation_token])
        sr = SupportRepresentative.accept_invitation(user_params, params[:invitation_token])
        unless sr.errors.any?
          sr.login!
          serialization = SupportRepresentativeSerializer.new(sr, {show_token: true})
          render_success(serialization.as_json)
        else
          error = sr.errors.full_messages.join(', ')
          render_error(RESPONSE_CODE[:unprocessable_entity], error)
        end
      end

    end
  end
end


