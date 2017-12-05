require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe "CRUD" do
    it "should create a admin successfully" do
      expect {
        FactoryBot.create(:admin)
      }.to change(Admin, :count).by(1)
    end
    it "should update a admin successfully" do
      admin = FactoryBot.create(:admin)
      admin.first_name = 'blan'
      admin.save
      updated_admin = Admin.first
      expect(updated_admin.first_name).to eq('blan')
    end
    it "should delete a admin successfully" do
      admin = FactoryBot.create(:admin)
      expect {
        admin.delete
      }.to change(Admin, :count).by(-1)
    end
  end

  describe 'Methods' do
    it 'should return all messages' do
      admin = FactoryBot.create(:admin)
      FactoryBot.create_list(:message, 5)
      expect(admin.messages.count).to eq(5)
    end
    it 'should return all ticekts' do
      admin = FactoryBot.create(:admin)
      FactoryBot.create_list(:ticket, 5)
      expect(admin.tickets.count).to eq(5)
    end
  end

  describe "User Invitation" do
    let(:user_params) do
      {
        email: Faker::Internet.email,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
      }

    end
    it "should invite a support representative successfully" do
      admin = FactoryBot.create(:admin)
      expect {
        admin.invite(user_params)
      }.to change(SupportRepresentative, :count).by(1)
    end

    it "should invite a support representative successfully" do
      admin = FactoryBot.create(:admin)
      sr = admin.invite(user_params)
      expect(sr.invitation_sent_at).not_to be_nil
    end
  end

end
