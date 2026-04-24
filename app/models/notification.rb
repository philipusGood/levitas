class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notificable, optional: true, polymorphic: true

  validates :content, presence: true

  def hours_since
    ((DateTime.now.in_time_zone('UTC') - self.created_at.in_time_zone('UTC')) / 3600).floor
  end

  def days_since
    (((DateTime.now.in_time_zone('UTC') - self.created_at.in_time_zone('UTC')) / 3600) / 24).floor
  end

  scope :last_24_hours, -> { where('created_at >= ?', 24.hours.ago) }
  scope :last_7_days, -> { where('created_at >= ?', 7.days.ago).where("created_at < ?", 24.hours.ago) }
  scope :older, -> { where('created_at < ?', 7.days.ago) }
end
