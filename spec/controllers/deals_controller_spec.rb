require 'rails_helper'

RSpec.describe DealsController, type: :controller do
  let(:user) { create(:user, role: "admin") }

  before do
    sign_in(user)
  end

  describe "POST#create" do
    it "creates a draft deal" do
     expect { post :create }.to change(Deal, :count).by(1)
    end
  end

  describe "GET#show" do
    let(:broker) { create(:user, role: 'broker') }
    let(:deal) { create(:deal, user: broker) }

    subject { get :show, params: { id: deal.id } }

    context "when admin" do
      it "renders deal" do
        subject

        expect(response).to render_template(:show)
      end
    end

    context "when broker" do
      let(:user) { broker }

      it "renders deal" do
        subject

        expect(response).to render_template(:show)
      end

      context "without deal ownership" do
        let(:deal) { create(:deal, user: create(:user, role: "broker"))}

        it "does not render deal" do
          expect { subject }.to raise_error
        end
      end
    end

    context "when lender" do
      let(:user) { create(:user, role: "lender") }

      context "with deal association" do
        before do
          deal.lenders << user.as_lender
        end

        it "renders deal" do
          subject

          expect(response).to render_template(:show)
        end
      end

      context "with public deal" do
        before do
          deal.change_to_public!
        end

        it "renders deal" do
          subject

          expect(response).to render_template(:show)
        end
      end

      context "with private deal" do
        before do
          deal.change_to_private!
        end

        it "does not render deal" do
          expect { subject }.to raise_error
        end
      end
    end
  end

  describe "GET#edit" do
    let(:user) { create(:user, role: 'admin') }
    let(:deal) { create(:deal, user: user) }

    it "renders edit template" do
      get :edit, params: { id: deal.id }

      expect(response).to render_template(:edit)
    end
  end

  describe "PUT#update" do
    let(:user) { create(:user, role: 'admin') }
    let(:deal) { create(:deal, user: user) }

      let(:deal_details) do
        {
          "loan_purpose" => {
            "funds_usage" => "The borrower intends to use the loan proceeds to renovate the property, increase its market value, and attract potential buyers.",
            "exit_strategy" => "The borrower plans to refinance the loan with a conventional lender upon completion of the renovations, ensuring timely repayment and maximizing returns on the investment."
          },
          "terms" => {
            "type" => "Refinance",
            "terms" => "10",
            "public" => "1",
            "lenders_fee" => "0",
            "interest_rate" => "0",
            "mortgage_principal" => "1000",
            "amortization_period" => "5 Years"
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
              "postal_code" => "M5V 3L9"
            },
            "mls_number" => "",
            "approximate_closing_date" => Faker::Date.forward(days: 30).to_s
          },
          "guarantor" => {},
          "applicant" => {
            "email" => Faker::Internet.email,
            "title" => "Mr",
            "assets" => {
              "0" => {
                "type" => "Vehicles",
                "amount" => "10",
                "description" => Faker::Vehicle.make_and_model
              },
              "1" => {
                "type" => "Real Estate",
                "amount" => "10",
                "mortage" => "true",
                "description" => Faker::Lorem.words(number: 3).join(" "),
                "property_type" => Faker::Lorem.word,
                "monthly_payment" => "2000",
                "balance_remaining" => "1000"
              }
            },
            "address" => {
              "city" => "Toronto",
              "unit" => "",
              "street" => Faker::Address.street_name,
              "country" => "Canada",
              "province" => "Ontario",
              "postal_code" => "M5V 3L9"
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
                "postal_code" => "M5V 3L9"
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
            "social_insurance_number" => "000-000-000"
          },
          "secondary_applicant" => {
            "email" => Faker::Internet.email,
            "title" => "Mr",
            "assets" => {
              "0" => {
                "type" => "Vehicles",
                "amount" => "10",
                "description" => Faker::Vehicle.make_and_model
              },
              "1" => {
                "type" => "Real Estate",
                "amount" => "10",
                "mortage" => "true",
                "description" => Faker::Lorem.words(number: 3).join(" "),
                "property_type" => Faker::Lorem.word,
                "monthly_payment" => "2000",
                "balance_remaining" => "1000"
              }
            },
            "address" => {
              "city" => "Toronto",
              "unit" => "",
              "street" => Faker::Address.street_name,
              "country" => "Canada",
              "province" => "Ontario",
              "postal_code" => "M5V 3L9"
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
                "postal_code" => "M5V 3L9"
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
            "social_insurance_number" => "000-000-000"
          },
          "broker_fees" => {
            "fees" => [
              {
                "default" => true,
                "amount_fee" => "0",
                "broker_name" => Faker::Name.name
              }
            ]
          },
        }
      end


    context "with valid params" do
      it "updates deal details" do
        put :update, params: { id: deal.id, deal: deal_details }

        expect(response).to redirect_to(deal_path(deal))
      end
    end

    context "with invalid params" do
      before do
        deal_details["applicant"]["email"] = "invalidemail"
      end

      it "renders edit template" do
        put :update, params: { id: deal.id, deal: deal_details }

        expect(response).to render_template(:edit)
      end
    end
  end
end
