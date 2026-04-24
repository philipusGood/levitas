require 'rails_helper'

RSpec.describe Deal::BrokerFee, type: :model do
  let(:valid_item_attributes) do
    {
      'broker_name' => 'Some Broker',
      'amount_fee' => 100.0,
      'default' => true
    }
  end

  let(:invalid_item_attributes) do
    {
      'broker_name' => nil,
      'amount_fee' => 100.0,
      'default' => true
    }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      broker_fee = described_class.new([valid_item_attributes])
      expect(broker_fee).to be_valid
    end

    it 'is invalid with invalid item attributes' do
      broker_fee = described_class.new([invalid_item_attributes])
      expect(broker_fee).not_to be_valid
    end
  end

  describe 'build_default_item' do
    it 'adds a new item to items' do
      broker_fee = described_class.new
      expect {
        broker_fee.build_default_item(valid_item_attributes)
      }.to change(broker_fee.items, :count).by(1)
    end
  end

  describe 'serialize' do
    it 'returns a serialized array of items' do
      broker_fee = described_class.new([valid_item_attributes])

      expect(broker_fee.serialize).to eq([{ broker_name: 'Some Broker', amount_fee: 100.0, default: true }])
    end
  end
end
