require 'rails_helper'

RSpec.describe Deal::Income, type: :model do
  describe "validations" do
    it "is valid with valid items" do
      item = {type: "Salary", period: "Monthly", amount: 5000}
      deal_income = Deal::Income.new([item])

      expect(deal_income).to be_valid
    end

    it "is invalid with invalid items" do
      item = {type: "Salary", period: "Monthly", amount: -5000}
      deal_income = Deal::Income.new([item])

      expect(deal_income).not_to be_valid
    end
  end

  describe "#build_default_item" do
    it "adds a new item to the items array" do
      deal_income = Deal::Income.new
      expect {
        deal_income.build_default_item
      }.to change { deal_income.items.length }.by(1)
    end
  end

  describe "#serialize" do
    it "serializes the items correctly" do
      item = {type: "Salary", period: "Monthly", amount: 5000}
      deal_income = Deal::Income.new([item])

      expect(deal_income.serialize).to eq([{ type: "Salary", period: "Monthly", amount: 5000 }])
    end
  end

  describe "#total" do
    it "calculates the total correctly" do
      item1 = {type: "Salary", period: "Monthly", amount: 5000}
      item2 = {type: "Bonus", period: "Quarterly", amount: 2000}
      deal_income = Deal::Income.new([item1, item2])

      expect(deal_income.total).to eq(68000.0)
    end
  end
end