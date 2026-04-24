FactoryBot.define do
  factory :broker do
    email { Faker::Internet.email }
    password { "Password123!"}
  end
end
