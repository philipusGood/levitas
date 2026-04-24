require 'rails_helper'

describe Deal do
  context 'with aasm' do
    let(:deal) { create(:deal) }

    it 'defaults state is draft' do
      expect(deal.state).to eq('draft')
    end

    it 'transitions to submitted' do
      deal.submit!
      expect(deal.state).to eq('submitted')
    end
  end

  context '#methods' do
    let(:deal) { create(:deal) }

    it 'detects when a secondary applicant is present' do
      expect(deal.secondary_applicant).to be_truthy
    end

    it 'returns an applicant' do
      expect(deal.applicant).to be_a(Deal::Applicant)
    end

    it 'returns an secondary applicant' do
      expect(deal.applicant).to be_a(Deal::Applicant)
    end


    it 'returns a property' do
      expect(deal.property).to be_a(Deal::Property)
    end

    it 'returns deal terms' do
      expect(deal.terms).to be_a(Deal::Term)
    end

    it 'returns broke fees' do
      expect(deal.broker_fees).to be_a(Deal::BrokerFee)
    end

    it 'returns credit check' do
      expect(deal.credit_check).to be_a(Deal::CreditCheck)
    end

    it 'assigns applicant attributes' do
      deal.applicant = { first_name: 'Jonh' }

      expect(deal.applicant.first_name).to eq('Jonh')
    end

    it 'assigns secondary applicant attributes' do
      deal.secondary_applicant = { first_name: 'Jonh' }

      expect(deal.secondary_applicant.first_name).to eq('Jonh')
    end

    it 'assigns property attributes' do
      deal.property = { type: 'Vacant Land' }

      expect(deal.property.type).to eq('Vacant Land')
    end

    it 'assigns terms attributes' do
      deal.terms = { type: 'Refinance' }

      expect(deal.terms.type).to eq('Refinance')
    end

    it 'assigns broker fees attributes' do
      deal.broker_fees = [{
        "default" => true,
        "amount_fee" => "100",
        "broker_name" => Faker::Name.name
      }]

      expect(deal.broker_fees.items.count).to eq(1)
      expect(deal.broker_fees.items.first.amount_fee).to eq("100")
    end


    it 'assigns credit check attributes' do
      deal.credit_check = { accept_terms: true }

      expect(deal.credit_check.accept_terms).to eq(true)
    end

    it "returns monthly paymet consisting of just the interest, for 'Interest Only' deals" do
      deal.terms = {
        amortization_period: 'Interest Only',
        mortgage_principal: '50000',
        lenders_fee: '5',
        interest_rate: '15'
      }

      # Should calculate on principal only: $50,000 * 15% / 12 = $625
      # NOT on $52,500 (with 5% lender fee) which would be $656.25
      expect(deal.monthly_cost).to eq(625.00)
    end

    it "returns correct monthly payment for deal with positive interest rate and amortization period" do
      deal.terms = {
        amortization_period: '25 Years',
        mortgage_principal: '50000',
        lenders_fee: '5',
        interest_rate: '15'
      }

      # Should calculate based on $50,000, not $52,500 (with lender fee)
      # Monthly payment for $50k at 15% over 25 years ≈ $640.42
      expect(deal.monthly_cost.round(2)).to eq(640.42)
    end

    it "returns monthly payment for deal with zero interest rate and amortization period" do
      deal.terms = {
        amortization_period: '25 Years',
        mortgage_principal: '50000',
        lenders_fee: '5',
        interest_rate: '0'
      }

      # Interest Rate will be set to 0.01
      # Should calculate on $50,000, not $52,500
      # Monthly payment for $50k at 0.01% over 25 years ≈ $188.44
      expect(deal.monthly_cost.round(2)).to eq(188.44)
    end

    it "does not include lender fee in monthly payment calculation for GDS/TDS" do
      deal.terms = {
        amortization_period: 'Interest Only',
        mortgage_principal: '80000',
        lenders_fee: '9',
        interest_rate: '12'
      }

      # Monthly payment should be: $80,000 * 12% / 12 = $800
      # NOT $87,200 * 12% / 12 = $872 (which would include the 9% lender fee)
      expect(deal.monthly_cost).to eq(800.00)
    end

    it "sets approved_signatures_at on state transition" do
      deal.update(state: "signatures")

      deal.approve_signatures!

      expect(deal.reload.approved_signatures_at).to_not be_nil
    end
  end

  context "#url_code" do
    let(:deal) { create(:deal) }

    it "creates deals with a short url code" do
      expect(deal.url_code).to_not be_nil
    end
  end
end


context 'Gross Service Ratio' do
  let(:deal) { create(:deal) }

  it 'calculates GSR correctly when there is no secondary applicant' do
    allow(deal.applicant).to receive_message_chain(:employer, :income, :total).and_return(120_000)
    allow(deal).to receive(:monthly_cost).and_return(1_000)
    allow(deal.applicant).to receive(:monthly_mortgage_payment).and_return(500)

    expect(deal.GSR).to be_within(14.2).of(14.4)
  end

  it 'calculates GSR correctly when there is a secondary applicant' do
    allow(deal).to receive(:has_secondary_applicant?).and_return(true)
    allow(deal.applicant).to receive_message_chain(:employer, :income, :total).and_return(120_000)
    allow(deal.secondary_applicant).to receive_message_chain(:employer, :income, :total).and_return(60_000)
    allow(deal).to receive(:monthly_cost).and_return(1_000)
    allow(deal.applicant).to receive(:monthly_mortgage_payment).and_return(500)
    allow(deal.secondary_applicant).to receive(:monthly_mortgage_payment).and_return(300)
    allow(deal.applicant).to receive(:has_employer?).and_return(true)
    allow(deal.secondary_applicant).to receive(:has_employer?).and_return(true)
    allow(deal).to receive(:GSR).and_return(12)

    expect(deal.GSR).to eq(12)
  end
end

describe 'Loan to Value Calculations' do
  let(:deal) { create(:deal) }

  it 'calculates LVR using total_mortgage_principal (requested amount + fees)' do
    deal.terms = { mortgage_principal: '50000', lenders_fee: '5', type: 'Purchase' }
    deal.property = { price: '100000' }
    deal.broker_fees = []

    # Total fees = lender fee (2500) + broker fees (0) + notary (2000) = 4500
    # Total mortgage principal = 50000 + 4500 = 54500
    # LVR = 54500 / 100000 = 54.5%
    expect(deal.LVR).to be_within(0.1).of(54.5)
  end

  it 'calculates LVR correctly with existing mortgages' do
    deal.terms = { mortgage_principal: '50000', lenders_fee: '5', type: 'Purchase' }
    deal.property = { price: '100000', mortgages: [{ amount_due: '20000', monthly_payment: '500', institution: 'Bank', end_date: '2026-01-01' }] }
    deal.broker_fees = []

    # Total mortgage principal = 50000 + 4500 = 54500
    # Plus existing mortgage: 54500 + 20000 = 74500
    # LVR = 74500 / 100000 = 74.5%
    expect(deal.LVR).to be_within(0.1).of(74.5)
  end

  it 'calculates total_mortgage_principal including all fees' do
    deal.terms = { mortgage_principal: '50000', lenders_fee: '8' }
    deal.broker_fees = [{ "default" => true, "amount_fee" => "1000", "broker_name" => "Test Broker" }]

    # Total fees = lender fee (4000) + broker fees (1000) + notary (2000) = 7000
    # Total mortgage principal = 50000 + 7000 = 57000
    expect(deal.total_mortgage_principal).to eq(57000)
  end
end
