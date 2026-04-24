require 'rails_helper'

RSpec.describe Deal::Address, type: :model do
  subject(:address) { described_class.new }

  context 'validations' do
    it { should validate_presence_of(:street) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:province) }
    it { should validate_presence_of(:country) }
    it { should validate_presence_of(:postal_code) }
    it { should allow_value('M5V 3L9').for(:postal_code) }
  end

  context 'attributes' do
    it { is_expected.to respond_to(:street) }
    it { is_expected.to respond_to(:unit) }
    it { is_expected.to respond_to(:city) }
    it { is_expected.to respond_to(:province) }
    it { is_expected.to respond_to(:country) }
    it { is_expected.to respond_to(:postal_code) }
  end

  context 'methods' do
    describe '#serialize' do
      it 'returns a hash with serialized attributes' do
        address.street = '123 Main St'
        address.city = 'Some City'
        address.province = 'Some Province'
        address.country = 'Some Country'
        address.postal_code = 'A1B 2C3'

        expected_result = {
          street: '123 Main St',
          unit: nil,
          city: 'Some City',
          province: 'Some Province',
          country: 'Some Country',
          postal_code: 'A1B 2C3'
        }

        expect(address.serialize).to eq(expected_result)
      end
    end

    describe '#full_address' do
      it 'returns the full address' do
        address.street = '123 Main St'
        address.unit = 'Apt 101'
        address.city = 'Some City'
        address.province = 'Some Province'
        address.country = 'Some Country'
        address.postal_code = 'A1B 2C3'

        expected_result = 'Apt 101-123 Main St, Some City, Some Province, A1B 2C3'
        expect(address.full_address).to eq(expected_result)
      end
    end
  end
end
