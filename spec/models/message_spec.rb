require 'rails_helper'

RSpec.describe Message, type: :model do
  describe "CRUD" do
    it "should create a message successfully" do
      expect {
        FactoryBot.create(:message)
      }.to change(Message, :count).by(1)
    end
    it "should update a message successfully" do
      message = FactoryBot.create(:message)
      message.content = 'blan'
      message.save
      updated_message = Message.first
      expect(updated_message.content).to eq('blan')
    end
    it "should delete a message successfully" do
      message = FactoryBot.create(:message)
      expect {
        message.delete
      }.to change(Message, :count).by(-1)
    end
  end
end


