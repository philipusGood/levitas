FactoryBot.define do
  factory :lender do
    email { Faker::Internet.email }
    password { "Password123!" }
  end
end
