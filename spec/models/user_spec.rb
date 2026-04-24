# spec/models/user_spec.rb

require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it { should validate_presence_of(:title).on(:account_setup) }
    it { should validate_presence_of(:first_name).on(:account_setup) }
    it { should validate_presence_of(:last_name).on(:account_setup) }
    it { should validate_presence_of(:birth_date).on(:account_setup) }
    it { should validate_presence_of(:phone_number).on(:account_setup) }
    it { should validate_presence_of(:address_street).on(:account_setup) }
    it { should validate_presence_of(:address_city).on(:account_setup) }
    it { should validate_presence_of(:address_province).on(:account_setup) }
    it { should validate_presence_of(:address_country).on(:account_setup) }
    it { should validate_presence_of(:address_postal_code).on(:account_setup) }
  end

  describe "scopes" do
    it "returns users matching search query" do
      user1 = create(:user, email: 'user1@example.com', profile: { first_name: 'John', last_name: 'Doe' })
      user2 = create(:user, email: 'user2@example.com', profile: { first_name: 'Jane', last_name: 'Doe' })
      user3 = create(:user, email: 'user3@example.com', profile: { first_name: 'Sam', last_name: 'Smith' })

      expect(User.search('Doe')).to contain_exactly(user1, user2)
    end

    it "returns all users when query is empty" do
      user1 = create(:user, email: 'user1@example.com', profile: { first_name: 'John', last_name: 'Doe' })
      user2 = create(:user, email: 'user2@example.com', profile: { first_name: 'Jane', last_name: 'Doe' })
      user3 = create(:user, email: 'user3@example.com', profile: { first_name: 'Sam', last_name: 'Smith' })

      expect(User.search('')).to contain_exactly(user1, user2, user3)
    end
  end

  describe "methods" do
    it "returns true for pending_account_setup? when profile is empty" do
      user = build(:user, profile: {})
      expect(user.pending_account_setup?).to be(true)
    end

    it "returns true for pending_account_setup? when validations fail" do
      user = build(:user, profile: { first_name: 'John' }) # Missing last_name, which is required
      expect(user.pending_account_setup?).to be(true)
    end

    it "returns false for pending_account_setup? when profile is not empty and validations pass" do
      user = build(:user, profile: { first_name: 'John', last_name: 'Doe', title: 'Mr.', birth_date: '1990-01-01', phone_number: '1234567890', address_street: '123 Main St', address_city: 'City', address_province: 'Province', address_country: 'Country', address_postal_code: '12345' })
      expect(user.pending_account_setup?).to be(false)
    end

    it "returns the full name" do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end

    it "returns true for invited? when invitation_sent_at is present" do
      user = build(:user, invitation_sent_at: Time.now)
      expect(user.invited?).to be(true)
    end

    it "returns false for invited? when invitation_sent_at is nil" do
      user = build(:user, invitation_sent_at: nil)
      expect(user.invited?).to be(false)
    end
  end
end
