require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe "CRUD" do
    it "should create a ticket successfully" do
      expect {
        FactoryBot.create(:ticket)
      }.to change(Ticket, :count).by(1)
    end
    it "should update a ticket successfully" do
      ticket = FactoryBot.create(:ticket)
      ticket.title = 'blan'
      ticket.save
      updated_ticket = Ticket.first
      expect(updated_ticket.title).to eq('blan')
    end
    it "should delete a ticket successfully" do
      ticket = FactoryBot.create(:ticket)
      expect {
        ticket.delete
      }.to change(Ticket, :count).by(-1)
    end
  end

  describe "Methods" do
    it "should assign a support representatve successfully" do
      support_representative = FactoryBot.create(:support_representative)
      ticket = FactoryBot.create(:ticket)
      ticket.assign_support_representative(support_representative)
      expect(ticket.status).to eq('assigned')
      expect(ticket.assigned_to_id).to eq(support_representative.id)
    end
    it "should not assign a ticket to any other user type" do
      admin = FactoryBot.create(:admin)
      ticket = FactoryBot.create(:ticket)
      expect {
        ticket.assign_support_representative(admin)
      }.to raise_error(ActiveRecord::AssociationTypeMismatch)
    end
    it 'should resolve a ticket if it has been assigned' do
      support_representative = FactoryBot.create(:support_representative)
      ticket = FactoryBot.create(:ticket)
      ticket.assign_support_representative(support_representative)
      ticket.resolve
      ticket.reload
      expect(ticket.status).to eq('closed')
    end
    it 'should not resolve a ticket if it has not been assigned' do
      support_representative = FactoryBot.create(:support_representative)
      ticket = FactoryBot.create(:ticket)
      ticket.resolve
      expect(ticket.errors.count).to eq(1)
    end
  end
end
