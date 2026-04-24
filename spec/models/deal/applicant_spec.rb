require 'rails_helper'

RSpec.describe Deal::Applicant, type: :model do
  let(:deal) { create(:deal) }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:birth_date) }
    it { should allow_value('1994-03-23').for(:birth_date) }
    it { should validate_presence_of(:email) }
    it { should allow_value('user@example.com').for(:email) }
    it { should validate_presence_of(:phone_number) }
  end


  describe 'serialize' do
    it 'serialize the model' do
      applicant = described_class.new(deal['details']['applicant'])

      expect(applicant.serialize.keys).to eq([
        :title,
        :first_name,
        :last_name,
        :birth_date,
        :social_insurance_number,
        :email,
        :phone_number,
        :address,
        :employer,
        :assets,
        :liabilities,
        :credit_score,
        :credit_score_source,
        :credit_score_report_date
      ])
    end
  end

  describe 'methods' do
    it 'has a full name' do
      deal.applicant.first_name = 'Jonh'
      deal.applicant.last_name = 'Wick'

      applicant = described_class.new(deal.applicant.serialize)

      expect(applicant.full_name).to eq('Jonh Wick')
    end

    it 'has a short name' do
      deal.applicant.first_name = 'Jonh'
      deal.applicant.last_name = 'Wick'

      applicant = described_class.new(deal.applicant.serialize)

      expect(applicant.short_full_name).to eq('JW')
    end


    context 'with liabilities' do
      it 'calculates total without real state assets' do
        deal.applicant.liabilities = Deal::Liabilities.new({
          taxes: 100,
          child_support: 100
        })

        applicant = described_class.new(deal.applicant.serialize)

        expect(applicant.liabilities_total).to eq(2300.0)
      end


      it 'calculates total with real state assets' do
        deal.applicant.liabilities = Deal::Liabilities.new({
          taxes: 100,
          child_support: 100
        })

        deal.applicant.assets = Deal::Assets.new([
          {
            type: 'Real Estate',
            amount: 1000,
            description: 'Asset Value',
            mortage: "true",
            property_type: SelectOptions::PROPERTY_TYPE.sample,
            balance_remaining: 4000,
            monthly_payment: 200
          }
        ])

        applicant = described_class.new(deal.applicant.serialize)

        expect(applicant.liabilities_total).to eq(5300.0)
      end
    end
  end
end
