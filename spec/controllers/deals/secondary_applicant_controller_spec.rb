require 'rails_helper'

RSpec.describe Deals::SecondaryApplicantController, type: :controller do
  let(:user) { create(:user, role: 'broker') }
  let(:deal) { create(:deal) }

  before do
    sign_in(user)
  end

  describe 'GET#show' do
    context 'when information step' do
      before do
        get :show, params: { id: 'information', deal_id: deal.id }
      end

      it 'renders information template' do
        expect(response).to render_template(:information)
      end

      it 'assigns applicant' do
        expect(assigns(:applicant)).to be_a(Deal::Applicant)
      end
    end


    context 'when income step' do
      before do
        get :show, params: { id: 'income', deal_id: deal.id }
      end

      it 'renders income template' do
        expect(response).to render_template(:income)
      end

      it 'assigns employer' do
        expect(assigns(:employer)).to be_a(Deal::Employer)
      end
    end


    context 'when assets step' do
      before do
        get :show, params: { id: 'assets', deal_id: deal.id }
      end

      it 'renders assets template' do
        expect(response).to render_template(:assets)
      end

      it 'assigns employer' do
        expect(assigns(:assets)).to be_a(Deal::Assets)
      end
    end

    context 'when liabilities step' do
      before do
        get :show, params: { id: 'liabilities', deal_id: deal.id }
      end

      it 'renders liabilities template' do
        expect(response).to render_template(:liabilities)
      end

      it 'assigns liabilities' do
        expect(assigns(:liabilities)).to be_a(Deal::Liabilities)
      end
    end
  end

  describe 'PUT#update' do
    context 'when information step' do
      before do
        put :update, params: { deal_id: deal.id, id: 'information', deal_applicant: attributes}
      end

      context 'with valid attributes' do
        let(:attributes) do
          {
            title: Faker::Name.prefix,
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            birth_date: Faker::Date.birthday(min_age: 19, max_age: 65),
            social_insurance_number: "#{Faker::Number.between(from: 100, to: 999)}-#{Faker::Number.between(from: 100, to: 999)}-#{Faker::Number.between(from: 100, to: 999)}",
            email: Faker::Internet.email,
            phone_number: Faker::PhoneNumber.phone_number,
            address: {
              street: Faker::Address.street_address,
              unit: Faker::Address.secondary_address,
              city: Faker::Address.city,
              province: Faker::Address.state,
              country: Faker::Address.country,
              postal_code: 'M5V 3L9'
            }
          }
        end

        it 'updates deal and redirect to next step' do
          expect(response).to redirect_to(deal_secondary_applicant_path(deal, 'income'))
        end
      end
    end

    context 'when income step' do
      before do
        put :update, params: { deal_id: deal.id, id: 'income', deal_employer: attributes}
      end

      context 'with valid attributes' do
        let(:attributes) do
          {
            name: Faker::Company.name,
            job_title: Faker::Job.title,
            industry_type: Faker::Company.industry,
            employment_type: Faker::Job.employment_type,
            duration_years: Faker::Number.between(from: 1, to: 30),
            duration_months: Faker::Number.between(from: 1, to: 12),
            phone_number: Faker::PhoneNumber.phone_number,
            fax: Faker::PhoneNumber.phone_number,
            email: Faker::Internet.email,
            ext: Faker::Number.number(digits: 4),
            income: [{
              type: "Asset Type",
              period: Faker::Time.between(from: DateTime.now - 365, to: DateTime.now, format: :short),
              amount: Faker::Number.between(from: 30000, to: 150000)
            }],
            address: {
              street: Faker::Address.street_address,
              unit: Faker::Address.secondary_address,
              city: Faker::Address.city,
              province: Faker::Address.state,
              country: Faker::Address.country,
              postal_code: 'M5V 3L9'
            }
          }
        end

        it 'updates deal and redirect to next step' do
          expect(response).to redirect_to(deal_secondary_applicant_path(deal, 'assets'))
        end
      end
    end

    context 'when assets step' do
      before do
        put :update, params: { deal_id: deal.id, id: 'assets', deal_assets: attributes}
      end

      context 'with valid attributes' do
        let(:attributes) do
          {
            assets: {
              "0" => {
                type: "Asset Type",
                description: "Asset description",
                amount: 1000,
              }
            }
          }
        end

        it 'updates deal and redirect to next step' do
          expect(response).to redirect_to(deal_secondary_applicant_path(deal, 'liabilities'))
        end
      end
    end

    context 'when liabilities step' do
      before do
        put :update, params: { deal_id: deal.id, id: 'liabilities', deal_liabilities: attributes}
      end

      context 'with valid attributes' do
        let(:attributes) do
          {
            taxes: 10,
            child_support: 20,
            bankruptcy: true,
            bankruptcy_status: 'active',
            expected_release_date: '2024-03-23',
            cost_of_release: Faker::Number.between(from: 500, to: 5000)
          }
        end

        it 'updates deal and redirect to next step' do
          expect(response).to redirect_to(deal_secondary_applicant_path(deal, 'wicked_finish'))
        end
      end
    end
  end
end
