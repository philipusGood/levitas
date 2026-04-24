require 'rails_helper'

RSpec.describe Deal::CreditCheck, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      credit_check = Deal::CreditCheck.new(accept_terms: true)
      expect(credit_check).to be_valid
    end

    it 'is invalid without accepting terms' do
      credit_check = Deal::CreditCheck.new(accept_terms: false)
      expect(credit_check).not_to be_valid
      expect(credit_check.errors[:accept_terms]).to_not be_empty
    end
  end

  describe '#serialize' do
    it 'returns a hash with accept_terms' do
      credit_check = Deal::CreditCheck.new(accept_terms: true)
      expect(credit_check.serialize).to eq({ accept_terms: true })
    end
  end
end





