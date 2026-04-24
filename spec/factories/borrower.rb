FactoryBot.define do
  factory :borrower do
    user
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    credit_score { Faker::Number.between(from: 300, to: 900) }

    after(:build) do |borrower|
      borrower.user.role = :borrower
    end
  end
end