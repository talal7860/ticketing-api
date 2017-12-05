require 'rails_helper'

RSpec.describe SupportRepresentative, type: :model do
  describe "CRUD" do
    it "should create a support_representative successfully" do
      expect {
        FactoryBot.create(:support_representative)
      }.to change(SupportRepresentative, :count).by(1)
    end
    it "should update a support_representative successfully" do
      support_representative = FactoryBot.create(:support_representative)
      support_representative.first_name = 'blan'
      support_representative.save
      updated_support_representative = SupportRepresentative.first
      expect(updated_support_representative.first_name).to eq('blan')
    end
    it "should delete a support_representative successfully" do
      support_representative = FactoryBot.create(:support_representative)
      expect {
        support_representative.delete
      }.to change(SupportRepresentative, :count).by(-1)
    end
  end

  describe "Accept Invitation" do
    let(:user_params) do
      {
        email: Faker::Internet.email,
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
      }
    end
    let(:password_params) do
      {
        password: 'password',
        password_confirmation: 'password'
      }
    end

    it "should successfully accept an invitation" do
      admin = FactoryBot.create(:admin)
      sr = admin.invite(user_params)
      user = SupportRepresentative.accept_invitation(password_params, sr.invitation_token)
      expect(user.invitation_accepted_at).not_to be_nil
    end

    it "should fail on invalid token" do
      admin = FactoryBot.create(:admin)
      sr = admin.invite(user_params)
      user = SupportRepresentative.accept_invitation(password_params, "123")
      expect(user).to be_nil
    end
  end
end

