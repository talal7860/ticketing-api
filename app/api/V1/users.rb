module V1
  class Users < Grape::API
    include V1Base
    include AuthenticateRequest
    include UserBase

    VALID_PARAMS = %w(first_name last_name email password password_confirmation)

    helpers do
      def user_params
        params.select{|key,value| VALID_PARAMS.include?(key.to_s)}
      end
    end

    resource :users do

      desc 'Update user', headers: HEADERS_DOCS, http_codes: [
        { code: 200, message: 'success' },
        { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') },
        { code: RESPONSE_CODE[:unprocessable_entity], message: 'Validation error messages' },
        { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
      ]
      params do
        requires :id, type: String, desc: 'Id'
        optional :email, type: String, desc: 'Email'
        optional :password, type: String, desc: 'Password'
        optional :password_confirmation, type: String, desc: 'Password'

        optional :first_name, type: String, desc: 'First name'
        optional :last_name, type: String, desc: 'Last name'
      end
      put ':id' do
        authenticate_admin!
        get_user(params[:id])

        if @user.update_attributes(customer_params)
          @user.reload

          serialization = UserSerializer.new(@user, {show_token: false})
          render_success(serialization.as_json)
        else
          error = @user.errors.full_messages.join(', ')
          render_error(RESPONSE_CODE[:unprocessable_entity], error)
          return
        end
      end

      desc 'Get user', headers: HEADERS_DOCS, http_codes: [
        { code: 200, message: 'success' },
        { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
      ]
      params do
        requires :id, type: String, desc: 'Customer id'
      end
      get ':id' do
        authenticate_admin!
        get_user(params[:id])

        serialization = UserSerializer.new(@user, {show_token: false})
        render_success(serialization.as_json)
      end


      desc 'Get customers', headers: HEADERS_DOCS, http_codes: [
        { code: 200, message: 'success' },
        { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
      ]
      params do
        optional :page, type: Integer, desc: 'page'
        optional :per_page, type: Integer, desc: 'per_page'
      end
      get :customers do
        authenticate!

        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || PER_PAGE).to_i
        customers = Customer.order("created_at DESC").page(page).per(per_page)

        serialization = ActiveModel::Serializer::CollectionSerializer.new(customers, each_serializer: CustomerSerializer, show_token: false)

        render_success({customers: serialization.as_json}, pagination_dict(customers))
      end

      desc 'Get Support Representatives', headers: HEADERS_DOCS, http_codes: [
        { code: 200, message: 'success' },
        { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') }
      ]
      params do
        optional :page, type: Integer, desc: 'page'
        optional :per_page, type: Integer, desc: 'per_page'
      end

      get :support_representatives do
        authenticate_admin!

        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || PER_PAGE).to_i
        support_representatives = SupportRepresentative.order("created_at DESC").page(page).per(per_page)

        serialization = ActiveModel::Serializer::CollectionSerializer.new(support_representatives, each_serializer: SupportRepresentative, show_token: false)

        render_success({support_representatives: serialization.as_json}, pagination_dict(support_representatives))
      end

      desc 'Delete a user', {
        consumes: [ "application/x-www-form-urlencoded" ],
        http_codes: [
          { code: 200, message: 'success' },
          { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') },
          { code: RESPONSE_CODE[:unauthorized], message: I18n.t('errors.unauthorized') }
        ]
      }
      params do
        requires :id, type: String, desc: 'ID'
      end

      delete ':id' do
        authenticate_admin!
        get_user(params[:id])
        @user.destroy
        render_success({deleted: true})
      end

    end
  end
end

