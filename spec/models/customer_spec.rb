require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe "CRUD" do
    it "should create a customer successfully" do
      expect {
        FactoryBot.create(:customer)
      }.to change(Customer, :count).by(1)
    end
    it "should update a customer successfully" do
      customer = FactoryBot.create(:customer)
      customer.first_name = 'blan'
      customer.save
      updated_customer = Customer.first
      expect(updated_customer.first_name).to eq('blan')
    end
    it "should delete a customer successfully" do
      customer = FactoryBot.create(:customer)
      expect {
        customer.delete
      }.to change(Customer, :count).by(-1)
    end
  end
end

