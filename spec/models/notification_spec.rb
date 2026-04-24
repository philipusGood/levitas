require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:notificable).optional(true) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content) }
  end

  describe '#hours_since' do
    it 'returns the number of hours since the notification was created' do
      notification = create(:notification, created_at: 3.hours.ago)
      expect(notification.hours_since).to eq(3)
    end
  end

  describe '#days_since' do
    it 'returns the number of days since the notification was created' do
      notification = create(:notification, created_at: 3.days.ago)
      expect(notification.days_since).to eq(3)
    end
  end

  describe 'scopes' do
    describe '.last_24_hours' do
      it 'returns notifications created in the last 24 hours' do
        create(:notification, created_at: 23.hours.ago)
        create(:notification, created_at: 25.hours.ago)
        expect(Notification.last_24_hours.count).to eq(1)
      end
    end

    describe '.last_7_days' do
      it 'returns notifications created in the last 7 days but not in the last 24 hours' do
        create(:notification, created_at: 6.days.ago)
        create(:notification, created_at: 8.days.ago)
        create(:notification, created_at: 1.hour.ago)
        expect(Notification.last_7_days.count).to eq(1)
      end
    end
  end
end
