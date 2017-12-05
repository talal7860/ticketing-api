FactoryBot.define do
  factory :ticket do
    association :owner, factory: :customer
    title { Faker::Lorem.word }
    description { Faker::Lorem.sentence  }
  end
end

