# spec/models/deal/term_spec.rb

require 'rails_helper'

RSpec.describe Deal::Term, type: :model do
  describe "validations" do
    it { should validate_presence_of(:mortgage_principal) }
    it { should validate_numericality_of(:lenders_fee).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:interest_rate).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:terms) }
    it { should validate_presence_of(:amortization_period) }
  end

  describe "serialization" do
    it "returns the serialized attributes" do
      term_attributes = {
        mortgage_principal: 300000,
        lenders_fee: 5000,
        interest_rate: 3.5,
        type: "Fixed",
        terms: 30,
        amortization_period: 25,
        public: true,
        payment_frecuency: "Monthly",
      }

      term = described_class.new(term_attributes)
      serialized_data = term.serialize

      expect(serialized_data).to eq({
        mortgage_principal: 300000,
        lenders_fee: 5000,
        interest_rate: 3.5,
        type: "Fixed",
        terms: 30,
        amortization_period: 25,
        prepayment_term: 0,
        public: true,
        payment_frecuency: "Monthly",
      })
    end
  end
end
