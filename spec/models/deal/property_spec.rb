require 'rails_helper'

RSpec.describe Deal::Property, type: :model do
  describe "validations" do
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:approximate_closing_date) }
    it { should allow_value('2030-09-18').for(:approximate_closing_date) }
    it { should_not allow_value('2021/09/18').for(:approximate_closing_date) }
  end

  describe "custom validations" do
    let(:property) { described_class.new }

    it "validates address" do
      address = Deal::Address.new # Assuming address is not valid
      property.address = address

      property.validate

      expect(property.errors[:base]).to_not be_empty
    end
  end

  describe "serialization" do
    it "returns the serialized attributes" do
      address_attributes = { street: "123 Main St", country: 'Canada', city: "Toronto", province: "Ontario", postal_code: "M5V 3L9", unit: '3' }
      property_attributes = {
        type: "Single Family",
        mls_number: "123456",
        price: 500000,
        approximate_closing_date: "2021-09-18",
        address: address_attributes,
        mortgages: [],
      }

      property = described_class.new(property_attributes)
      serialized_data = property.serialize

      expect(serialized_data).to eq({
        type: "Single Family",
        mls_number: "123456",
        price: 500000,
        approximate_closing_date: "2021-09-18",
        address: address_attributes,
        mortgages: [],
      })
    end
  end
end
