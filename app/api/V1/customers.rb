module V1
  class Customers < Grape::API
    include V1Base
    include AuthenticateRequest
    include UserBase

    VALID_PARAMS = %w(first_name last_name email password password_confirmation)

    helpers do
      def customer_params
        params.select{|key,value| VALID_PARAMS.include?(key.to_s)}
      end
    end

    resource :customers do

      desc 'Create new customer', {
        consumes: [ "application/x-www-form-urlencoded" ],
        http_codes: [
          { code: 200, message: 'success' },
          { code: RESPONSE_CODE[:unprocessable_entity], message: 'Detail error messages' }
        ]
      }
      params do
        requires :first_name, type: String, desc: 'Customer First name'
        requires :last_name, type: String, desc: 'Customer Last name'
        requires :email, type: String, desc: 'Customer email'
        requires :password, type: String, desc: 'Customer Password'
        requires :password_confirmation, type: String, desc: 'Customer Password'
      end
      post do
        customer = Customer.new(customer_params)
        if customer.save
          u_token = customer.login!

          serialization = CustomerSerializer.new(customer, {show_token: true, token: u_token.token})
          render_success(serialization.as_json)
        else
          error = customer.errors.full_messages.join(', ')
          render_error(RESPONSE_CODE[:unprocessable_entity], error)
          return
        end
      end


      desc 'Update customer', headers: HEADERS_DOCS, http_codes: [
        { code: 200, message: 'success' },
        { code: RESPONSE_CODE[:forbidden], message: I18n.t('errors.forbidden') },
        { code: RESPONSE_CODE[:unprocessable_entity], message: 'Validation error messages' },
        { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
      ]
      params do
        requires :id, type: String, desc: 'Customer id'
        optional :email, type: String, desc: 'Customer email'
        optional :password, type: String, desc: 'Customer Password'
        optional :password_confirmation, type: String, desc: 'Customer Password'

        optional :first_name, type: String, desc: 'Customer First name'
        optional :last_name, type: String, desc: 'Customer Last name'
      end
      put ':id' do
        authenticate!
        can_update_customer?(params[:id])

        if current_user.update_attributes(customer_params)
          current_user.reload

          serialization = CustomerSerializer.new(current_user, {show_token: false})
          render_success(serialization.as_json)
        else
          error = current_user.errors.full_messages.join(', ')
          render_error(RESPONSE_CODE[:unprocessable_entity], error)
          return
        end
      end

      desc 'Get customers', headers: HEADERS_DOCS, http_codes: [
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
        customers = Customer.order("created_at DESC").page(page).per(per_page)

        serialization = ActiveModel::Serializer::CollectionSerializer.new(customers, each_serializer: CustomerSerializer, show_token: false)

        render_success(serialization.as_json, pagination_dict(customers))
      end

      desc 'Get customer', headers: HEADERS_DOCS, http_codes: [
        { code: 200, message: 'success' },
        { code: RESPONSE_CODE[:not_found], message: I18n.t('errors.not_found') }
      ]
      params do
        requires :id, type: String, desc: 'Customer id'
      end
      get ':id' do
        authenticate!
        get_user(params[:id])

        serialization = CustomerSerializer.new(@user, {show_token: false})
        render_success(serialization.as_json)
      end


    end
  end
end
