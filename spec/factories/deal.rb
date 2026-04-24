FactoryBot.define do
  factory :deal do
    user

    details {{
      "terms" => {
        "type" => "Refinance",
        "terms" => "10",
        "public" => "1",
        "lenders_fee" => "0",
        "interest_rate" => "0",
        "mortgage_principal" => "10000",
        "amortization_period" => "5 Years",
        "payment_frecuency" => "Monthly"
      },
      "property" => {
        "type" => "Vacant Land",
        "price" => "100000",
        "address" => {
          "city" => "Toronto",
          "unit" => "",
          "street" => Faker::Address.street_name,
          "country" => "Canada",
          "province" => "Alberta",
          "postal_code" => Faker::Address.zip_code
        },
        "mls_number" => "",
        "approximate_closing_date" => Faker::Date.forward(days: 30).to_s
      },
      "applicant" => {
        "email" => Faker::Internet.email,
        "title" => "Mr",
        "assets" => [
          {
            "type" => "Vehicles",
            "amount" => "10",
            "description" => Faker::Vehicle.make_and_model
          },
          {
            "type" => "Real Estate",
            "amount" => "10",
            "mortage" => "true",
            "description" => Faker::Lorem.words(number: 3).join(" "),
            "property_type" => Faker::Lorem.word,
            "monthly_payment" => "2000",
            "balance_remaining" => "1000"
          }
        ],
        "address" => {
          "city" => "Toronto",
          "unit" => "",
          "street" => Faker::Address.street_name,
          "country" => "Canada",
          "province" => "Ontario",
          "postal_code" => Faker::Address.zip_code
        },
        "employer" => {
          "ext" => "",
          "fax" => "",
          "name" => Faker::Company.name,
          "email" => "",
          "income" => [
            {
              "type" => "Employment Income",
              "amount" => "10000",
              "period" => "Monthly"
            },
            {
              "type" => "Business/Professional Income (Self-employed earnings)",
              "amount" => "2000",
              "period" => "Bi-Weekly (Every Two Weeks)"
            }
          ],
          "address" => {
            "city" => "Toronto",
            "unit" => "",
            "street" => Faker::Address.street_name,
            "country" => "Canada",
            "province" => "Ontario",
            "postal_code" => Faker::Address.zip_code
          },
          "job_title" => Faker::Job.title,
          "phone_number" => Faker::PhoneNumber.phone_number,
          "industry_type" => Faker::Company.industry,
          "duration_years" => "2",
          "duration_months" => "6",
          "employment_type" => "Full-Time"
        },
        "last_name" => Faker::Name.last_name,
        "birth_date" => Faker::Date.birthday(min_age: 18, max_age: 65).to_s,
        "first_name" => Faker::Name.first_name,
        "liabilities" => {
          "taxes" => "5000",
          "bankruptcy" => "true",
          "child_support" => "0",
          "cost_of_release" => "1000",
          "bankruptcy_status" => "true",
          "expected_release_date" => Faker::Date.forward(days: 30).to_s
        },
        "phone_number" => Faker::PhoneNumber.phone_number,
        "social_insurance_number" => Faker::IDNumber.valid
      },
      "secondary_applicant" => {
        "email" => Faker::Internet.email,
        "title" => "Mr",
        "assets" => [
          {
            "type" => "Vehicles",
            "amount" => "10",
            "description" => Faker::Vehicle.make_and_model
          },
          {
            "type" => "Real Estate",
            "amount" => "10",
            "mortage" => "true",
            "description" => Faker::Lorem.words(number: 3).join(" "),
            "property_type" => Faker::Lorem.word,
            "monthly_payment" => "2000",
            "balance_remaining" => "1000"
          }
        ],
        "address" => {
          "city" => "Toronto",
          "unit" => "",
          "street" => Faker::Address.street_name,
          "country" => "Canada",
          "province" => "Ontario",
          "postal_code" => Faker::Address.zip_code
        },
        "employer" => {
          "ext" => "",
          "fax" => "",
          "name" => Faker::Company.name,
          "email" => "",
          "income" => [
            {
              "type" => "Employment Income",
              "amount" => "10000",
              "period" => "Monthly"
            },
            {
              "type" => "Business/Professional Income (Self-employed earnings)",
              "amount" => "2000",
              "period" => "Bi-Weekly (Every Two Weeks)"
            }
          ],
          "address" => {
            "city" => "Toronto",
            "unit" => "",
            "street" => Faker::Address.street_name,
            "country" => "Canada",
            "province" => "Ontario",
            "postal_code" => Faker::Address.zip_code
          },
          "job_title" => Faker::Job.title,
          "phone_number" => Faker::PhoneNumber.phone_number,
          "industry_type" => Faker::Company.industry,
          "duration_years" => "2",
          "duration_months" => "6",
          "employment_type" => "Full-Time"
        },
        "last_name" => Faker::Name.last_name,
        "birth_date" => Faker::Date.birthday(min_age: 18, max_age: 65).to_s,
        "first_name" => Faker::Name.first_name,
        "liabilities" => {
          "taxes" => "5000",
          "bankruptcy" => "true",
          "child_support" => "0",
          "cost_of_release" => "1000",
          "bankruptcy_status" => "true",
          "expected_release_date" => Faker::Date.forward(days: 30).to_s
        },
        "phone_number" => Faker::PhoneNumber.phone_number,
        "social_insurance_number" => Faker::IDNumber.valid
      },
      "broker_fees" => [
        {
          "default" => true,
          "amount_fee" => "0",
          "broker_name" => Faker::Name.name
        }
      ],
      "credit_check" => {
        "accept_terms" => "1"
      }
    }}
  end
end
