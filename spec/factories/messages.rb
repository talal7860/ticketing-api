FactoryBot.define do
  factory :message do
    association :sender, factory: :customer
    association :ticket, factory: :ticket
    content { Faker::Lorem.sentence }
  end
end
