FactoryBot.define do
  factory :notification do
    association :user
    content { Faker::Lorem.sentence }
    created_at { Faker::Time.backward(days: 30) }

    before(:create) do |notification|
      deal = create(:deal)
      notification.notificable_id = deal.id
      notification.notificable_type = deal.class.to_s
    end
  end
end
