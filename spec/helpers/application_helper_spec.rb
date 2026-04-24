RSpec.describe ApplicationHelper, type: :helper do
  describe '#interest_rate_plus_lenders_fee' do
    let(:deal) { create(:deal) }

    context 'when interest_rate and lenders_fee are whole numbers' do
      before do
        deal.details["terms"]["interest_rate"] = 10
        deal.details["terms"]["lenders_fee"] = 5
      end
      
      it 'returns formatted string with 0 decimal places' do
        expect(helper.interest_rate_plus_lenders_fee(deal)).to eq('10% + 5%')
      end
    end
    
    context 'when interest_rate and lenders_fee have decimals' do
      before do
        deal.details["terms"]["interest_rate"] = 10.5
        deal.details["terms"]["lenders_fee"] = 5.5
      end
      
      it 'returns formatted string with 1 decimal place' do
        expect(helper.interest_rate_plus_lenders_fee(deal)).to eq('10.5% + 5.5%')
      end
    end
    
    context 'when interest_rate and lenders_fee are nil' do
      before do
        deal.details["terms"]["interest_rate"] = nil
        deal.details["terms"]["lenders_fee"] = nil
      end
      
      it 'returns formatted string with 0% for nil values' do
        expect(helper.interest_rate_plus_lenders_fee(deal)).to eq('0% + 0%')
      end
    end
  end
end
