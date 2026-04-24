require 'rails_helper'

RSpec.describe Deal::Assets, type: :model do
  describe Deal::Assets::Item do
    subject { Deal::Assets::Item.new }
    # it { should validate_presence_of(:type) }
    # it { should validate_presence_of(:description) }
    # it { should validate_presence_of(:amount) }
    # it { should validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }

    it 'vaidates type presence' do
      subject.valid?
      expect(subject.errors[:type]).to_not be_nil

      subject.type = 'Asset Type'
      subject.valid?
      expect(subject.errors[:type]).to be_empty
    end

    it 'vaidates description presence' do
      subject.valid?
      expect(subject.errors[:description]).to_not be_nil

      subject.description = 'Asset description'
      subject.valid?
      expect(subject.errors[:description]).to be_empty
    end

    it 'vaidates amount presence' do
      subject.valid?
      expect(subject.errors[:amount]).to_not be_nil

      subject.amount = 10
      subject.valid?
      expect(subject.errors[:amount]).to be_empty
    end
  end

  describe '#initialize' do
    it 'initializes with an array of items' do
      items = [{ type: 'Real Estate', description: 'Property 1', amount: 100000 }]
      assets = Deal::Assets.new(items)
      
      expect(assets.items.length).to eq(1)
    end
  end
  
  describe '#build_default_item' do
    it 'adds a new default item to the items array' do
      assets = Deal::Assets.new
      assets.build_default_item
      
      expect(assets.items.length).to eq(1)
    end
  end
  
  describe '#serialize' do
    it 'returns an array of serialized items' do
      items = [
        {type: 'Real Estate', description: 'Property 1', amount: 100000},
        {type: 'Other', description: 'Item 2', amount: 50000}
      ]
      assets = Deal::Assets.new(items)
      
      serialized = assets.serialize
      
      expect(serialized.length).to eq(2)
      expect(serialized[0][:type]).to eq('Real Estate')
      expect(serialized[0][:description]).to eq('Property 1')
      expect(serialized[0][:amount]).to eq(100000)
      expect(serialized[1][:type]).to eq('Other')
      expect(serialized[1][:description]).to eq('Item 2')
      expect(serialized[1][:amount]).to eq(50000)
    end
  end
end