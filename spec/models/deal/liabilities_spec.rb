require 'rails_helper'

RSpec.describe Deal::Liabilities, type: :model do
  subject(:liabilities) { described_class.new }

  it { is_expected.to validate_presence_of(:taxes) }
  it { is_expected.to validate_numericality_of(:taxes).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_presence_of(:child_support) }
  it { is_expected.to validate_presence_of(:bankruptcy) }
  it { is_expected.to validate_numericality_of(:child_support).is_greater_than_or_equal_to(0) }

  describe '#bankruptcy?' do
    it 'returns true if bankruptcy is "true"' do
      liabilities.bankruptcy = "true"
      expect(liabilities.bankruptcy?).to be_truthy
    end

    it 'returns false if bankruptcy is not "true"' do
      liabilities.bankruptcy = "false"
      expect(liabilities.bankruptcy?).to be_falsey
    end
  end

  describe '#serialize' do
    it 'returns a hash with taxes, child_support, and bankruptcy when bankruptcy is true' do
      liabilities = described_class.new(taxes: 100, child_support: 50, bankruptcy: "true")

      expect(liabilities.serialize).to eq({
        taxes: 100,
        child_support: 50,
        bankruptcy: "true",
        bankruptcy_status: nil,
        debt_obligations: [],
      })
    end

    it 'returns a hash with all fields when bankruptcy is true and bankruptcy_status is true' do
      liabilities = described_class.new(
        taxes: 100,
        child_support: 50,
        bankruptcy: "true",
        bankruptcy_status: "true",
        expected_release_date: "2023-09-18",
        cost_of_release: 200,
      )

      expect(liabilities.serialize).to eq({
        taxes: 100,
        child_support: 50,
        bankruptcy: "true",
        bankruptcy_status: "true",
        expected_release_date: "2023-09-18",
        cost_of_release: 200,
        debt_obligations: [],
      })
    end

    it 'returns a hash without bankruptcy fields when bankruptcy is false' do
      liabilities = described_class.new(taxes: 100, child_support: 50, bankruptcy: "false")

      expect(liabilities.serialize).to eq({
        taxes: 100,
        child_support: 50,
        bankruptcy: "false",
        debt_obligations: [],
      })
    end
  end

  describe '#total' do
    context 'when bankruptcy is not active' do
      it 'calculates total correctly' do
        liabilities = described_class.new(taxes: 100, child_support: 50, bankruptcy: "false")

        expect(liabilities.total).to eq(700)
      end
    end

    context 'when bankruptcy is active' do
      it 'calculates total with cost_of_release' do
        liabilities = described_class.new(
          taxes: 100,
          child_support: 50,
          bankruptcy: "true",
          bankruptcy_status: "active",
          cost_of_release: 200
        )

        expect(liabilities.total).to eq(700.0)
      end
    end
  end
end
