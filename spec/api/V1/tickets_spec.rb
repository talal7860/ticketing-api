require 'rails_helper'

describe ApplicationApi::V1::Sessions do
  include Rack::Test::Methods

  def app
    ApplicationApi
  end

  before(:context) do
  end

  context :customer do
    describe 'Authenticated Request' do
      let (:authenticate!) do
        customer = FactoryBot.create(:customer)
        customer.login!
        header 'Content-Type', 'application/json'
        header 'Authorization', customer.user_tokens.first.token
      end
      let (:ticket) do
        FactoryBot::build(:ticket, owner: nil)
      end

      it 'creates a ticket' do
        authenticate!
        post '/api/tickets', ticket.to_json

        expect(last_response.status).to eq(201)
        expect(JSON.parse(last_response.body)['data']['title']).to eq(ticket.title)
      end

      it 'deletes a ticket' do
        authenticate!
        ticket.owner = Customer.first
        ticket.save!
        delete "/api/tickets/#{ticket.id}"

        expect(last_response.status).to eq(200)
      end

      it 'gets only tickets owned by the customer' do
        authenticate!
        FactoryBot::create_list(:ticket, 5)
        FactoryBot::create_list(:ticket, 5, owner: Customer.first)
        get '/api/tickets/all'

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data'].count).to eq(5)
      end

      it 'gets details of a ticket' do
        authenticate!
        ticket.owner = Customer.first
        ticket.save!
        get "/api/tickets/#{ticket.id}"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data']['id']).to eq(ticket.id)
      end

      it 'does not get details of an unowned ticket' do
        authenticate!
        customer = FactoryBot.create(:customer)
        ticket.owner = customer
        ticket.save!
        get "/api/tickets/#{ticket.id}"
        expect(last_response.status).to eq(403)
      end

    end
    describe 'Un Authenticated Request' do
      let (:ticket) do
        FactoryBot::build(:ticket, owner: nil)
      end

      it 'does creates a ticket' do
        post '/api/tickets', ticket.to_json

        expect(last_response.status).to eq(400)
      end

      it 'does not deletes a ticket' do
        customer = FactoryBot.create(:customer)
        ticket.owner = customer
        ticket.save!
        delete "/api/tickets/#{ticket.id}"

        expect(last_response.status).to eq(401)
      end

      it 'does not get any ticket' do
        FactoryBot::create_list(:ticket, 5)
        get '/api/tickets/all'

        expect(last_response.status).to eq(401)
      end

      it 'doest not gets details of a ticket' do
        customer = FactoryBot.create(:customer)
        ticket.owner = customer
        ticket.save!
        get "/api/tickets/#{ticket.id}"
        expect(last_response.status).to eq(401)
      end

    end

  end

  context :support_representative do
    describe 'Authenticated Request' do
      let (:authenticate!) do
        support_representative = FactoryBot.create(:support_representative)
        support_representative.login!
        header 'Content-Type', 'application/json'
        header 'Authorization', support_representative.user_tokens.first.token
      end
      let (:ticket) do
        FactoryBot::build(:ticket, owner: nil)
      end

      it 'does not creates a ticket' do
        authenticate!
        post '/api/tickets', ticket.to_json

        expect(last_response.status).to eq(401)
      end

      it 'cannot delete a ticket' do
        authenticate!
        ticket.owner = FactoryBot.create(:customer)
        ticket.save!
        delete "/api/tickets/#{ticket.id}"

        expect(last_response.status).to eq(403)
      end

      it 'gets only tickets that are assigned or status is open' do
        authenticate!
        FactoryBot::create_list(:ticket, 5, assigned_to: SupportRepresentative.first, status: 'assigned')
        FactoryBot::create_list(:ticket, 5, owner: Customer.first)
        support_representative = FactoryBot.create(:support_representative)
        FactoryBot::create_list(:ticket, 5, owner: Customer.first, assigned_to: support_representative, status: 'assigned')
        get '/api/tickets/all'

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data'].count).to eq(10)
      end

      it 'gets details of a un assigned ticket' do
        authenticate!
        ticket.owner = FactoryBot.create(:customer)
        ticket.save!
        get "/api/tickets/#{ticket.id}"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data']['id']).to eq(ticket.id)
      end

      it 'can assign an unassigned ticket to itself' do
        authenticate!
        ticket = FactoryBot.create(:ticket)
        post "/api/tickets/#{ticket.id}/work"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data']['status']).to eq('assigned')
      end

      it 'can resolve an assigned ticket to itself' do
        authenticate!
        ticket = FactoryBot.create(:ticket, status: 'assigned', assigned_to: SupportRepresentative.first)
        post "/api/tickets/#{ticket.id}/resolve"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data']['status']).to eq('closed')
      end

      it 'cannot assign an assigned ticket to itself' do
        authenticate!
        ticket = FactoryBot.create(:ticket, status: 'assigned', assigned_to: FactoryBot.create(:support_representative))
        post "/api/tickets/#{ticket.id}/resolve"
        expect(last_response.status).to eq(403)
      end

      it 'cannot resolve an closed ticket' do
        authenticate!
        ticket = FactoryBot.create(:ticket, status: 'closed', assigned_to: FactoryBot.create(:support_representative))
        post "/api/tickets/#{ticket.id}/work"
        expect(last_response.status).to eq(403)
      end

      it 'can resolve an assigned ticket to itself' do
        authenticate!
        ticket = FactoryBot.create(:ticket, status: 'assigned', assigned_to: SupportRepresentative.first)
        post "/api/tickets/#{ticket.id}/resolve"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data']['status']).to eq('closed')
      end

      it 'does not get details of a ticket not assigned to him' do
        authenticate!
        ticket = FactoryBot::create(:ticket, assigned_to: FactoryBot.create(:support_representative), status: 'assigned')
        post "/api/tickets/#{ticket.id}"
        expect(last_response.status).to eq(405)
      end

    end
  end

  context :admin do
    describe 'Authenticated Request' do
      let (:authenticate!) do
        admin = FactoryBot.create(:admin)
        admin.login!
        header 'Content-Type', 'application/json'
        header 'Authorization', admin.user_tokens.first.token
      end
      let (:ticket) do
        FactoryBot::build(:ticket)
      end

      it 'can creates a ticket against any customer' do
        authenticate!
        ticket.owner = FactoryBot.create(:customer)
        post '/api/tickets', ticket.to_json

        expect(last_response.status).to eq(201)
      end

      it 'can deletes any ticket' do
        authenticate!
        ticket.owner = FactoryBot.create(:customer)
        ticket.save!
        delete "/api/tickets/#{ticket.id}"

        expect(last_response.status).to eq(200)
      end

      it 'gets all tickets' do
        authenticate!
        FactoryBot::create_list(:ticket, 5, assigned_to: SupportRepresentative.first, status: 'assigned')
        FactoryBot::create_list(:ticket, 5)
        FactoryBot::create_list(:ticket, 5, status: 'closed')
        get '/api/tickets/all'

        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data'].count).to eq(15)
      end

      it 'gets details of a any ticket' do
        authenticate!
        ticket = FactoryBot.create(:ticket)
        get "/api/tickets/#{ticket.id}"
        expect(last_response.status).to eq(200)
        expect(JSON.parse(last_response.body)['data']['id']).to eq(ticket.id)
      end

    end
  end
end
