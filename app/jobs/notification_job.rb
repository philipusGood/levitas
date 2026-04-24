class NotificationJob < ApplicationJob
  queue_as :default

  def perform(args)
    Notification.create!({
      content: args['content'],
      user_id: args['user_id'],
      notificable_id: args['notificable_id'],
      notificable_type: args['notificable_type'],
    })
  end
end
