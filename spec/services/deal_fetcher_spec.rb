require 'rails_helper'

RSpec.describe DealFetcher do
  let!(:user) { create(:user) }

  describe '#call' do
    context 'when user is an admin' do
      let!(:deals) { create_list(:deal, 5) }

      it 'returns all deals' do
        user.update(role: 'admin')
        deal_fetcher = described_class.new(user: user)

        expect(deal_fetcher.call.count).to eq(5)
      end
    end

    context 'when user is a broker' do
      let!(:deal) { create(:deal, user: user)}
      let!(:deals) { create_list(:deal, 5) }

      it 'returns user-specific deals' do
        user.update(role: 'broker')
        deal_fetcher = described_class.new(user: user)

        expect(deal_fetcher.call.count).to eq(1)
      end
    end

    context 'when user is a lender' do
      let!(:deals) { create_list(:deal, 5) }
      let!(:private_deal) { create(:deal) }
      let!(:lender_deal) { create(:deal) }

      before do
        private_deal.terms = Deal::Term.new(private_deal.terms.serialize.merge({ public: "false" }))
        private_deal.save
        user.update(role: 'lender')
        lender_deal.lenders << Lender.find(user.id)
      end

      it 'returns lender-specific deals' do
        deal_fetcher = described_class.new(user: user, params: { visibility: "private"})

        expect(deal_fetcher.call.count).to eq(1)
      end
    end
  end
end
