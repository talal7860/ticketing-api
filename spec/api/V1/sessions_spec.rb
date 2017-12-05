require 'rails_helper'

describe ApplicationApi::V1::Sessions do
  include Rack::Test::Methods

  def app
    ApplicationApi
  end

  describe 'POST /api/sessions' do
    let(:customer) { FactoryBot.create(:customer, email: 'customer@customer.com') }
    let (:body) do
      {
        email: 'customer@customer.com',
        password: 'password'
      }
    end

    it 'creates a token for logging in' do
      customer
      post '/api/sessions', body, { 'Content-Type' => 'application/json' }

      expect(last_response.status).to eq(201)
      expect(JSON.parse(last_response.body)['data']['token']).to eq(UserToken.first.token)
    end
  end

  describe 'DELETE /api/sessions' do
    let(:customer) { FactoryBot.create(:customer, email: 'customer@customer.com') }

    it 'creates a token for logging in' do
      customer.login!
      puts customer.user_tokens.first.token
      header 'Content-Type', 'application/json'
      header 'Authorization', customer.user_tokens.first.token
      delete '/api/sessions'

      expect(last_response.status).to eq(200)
      expect(customer.user_tokens.count).to eq(0)
    end
  end

end
