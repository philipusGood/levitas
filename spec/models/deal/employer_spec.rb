# spec/models/deal/employer_spec.rb
require 'rails_helper'

RSpec.describe Deal::Employer, type: :model do
  context 'methods' do
    let(:employer) { described_class.new({}) }

    describe '#duration' do
      it 'returns the correct duration' do
        employer.duration_years = 2
        employer.duration_months = 5
        expect(employer.duration).to eq('2 Years 5 Months')
      end

      it 'returns only years if months is zero' do
        employer.duration_years = 3
        employer.duration_months = 0
        expect(employer.duration).to eq('3 Years')
      end

      it 'returns only months if years is zero' do
        employer.duration_years = 0
        employer.duration_months = 7
        expect(employer.duration).to eq('7 Months')
      end

      it 'returns zero duration if both years and months are zero' do
        employer.duration_years = 0
        employer.duration_months = 0
        expect(employer.duration).to eq('')
      end
    end
  end

  describe '#serialize' do
    let(:employer) { described_class.new({}) }

    it 'returns a hash with serialized attributes' do
      employer.name = 'John Doe'
      employer.job_title = 'Developer'
      employer.industry_type = 'Tech'
      employer.employment_type = 'Full-Time'
      employer.duration_years = 2
      employer.duration_months = 6
      employer.phone_number = '123-456-7890'
      employer.ext = '123'
      employer.fax = '456-789-0123'
      employer.email = 'john.doe@example.com'
      employer.address = Deal::Address.new
      employer.income = Deal::Income.new

      expected_result = {
        name: 'John Doe',
        job_title: 'Developer',
        industry_type: 'Tech',
        employment_type: 'Full-Time',
        duration_years: 2,
        duration_months: 6,
        phone_number: '123-456-7890',
        ext: '123',
        fax: '456-789-0123',
        email: 'john.doe@example.com',
        address: {},
        income: []
      }

      expect(employer.serialize).to eq(expected_result)
    end

    it 'returns a hash without nil values' do
      employer.name = 'John Doe'
      employer.job_title = 'Developer'

      expected_result = {
        name: 'John Doe',
        job_title: 'Developer',
        address: {},
        duration_months: 0,
        duration_years: 0,
        email: nil,
        employment_type: nil,
        ext: nil,
        fax: nil,
        income: [],
        industry_type: nil,
        phone_number: nil,
      }

      expect(employer.serialize).to eq(expected_result)
    end
  end
end
