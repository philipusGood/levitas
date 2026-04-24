FactoryBot.define do
  factory :user do
    transient do
      skip_password_validation { false }
    end

    title { Faker::Name.prefix }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    middle_name { Faker::Name.middle_name }
    birth_date { '1994-03-23' }
    phone_number { Faker::PhoneNumber.phone_number }
    address_street { Faker::Address.street_address }
    address_unit { Faker::Address.secondary_address }
    address_city { Faker::Address.city }
    address_province { Faker::Address.state }
    address_country { Faker::Address.country }
    address_postal_code { Faker::Address.zip_code }

    email { Faker::Internet.unique.email }
    password { "Password123!" }
    password_confirmation { "Password123!" }
    confirmed_at { Time.now }
    role { :broker }
    approved_at { Time.now }

    after(:build) do |user, evaluator|
      user.skip_password_validation = evaluator.skip_password_validation
    end

    after(:create) do |user, evaluator|
      user.skip_password_validation = evaluator.skip_password_validation
      user.save(validate: !user.skip_password_validation)
    end
  end
end
