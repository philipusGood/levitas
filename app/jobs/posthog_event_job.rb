class PosthogEventJob
  include Sidekiq::Worker

  def perform(event_name, distinct_id, properties)
    properties = properties.merge(environment: Rails.env, event_source: "backend")

    $posthog.capture(
      distinct_id: distinct_id,
      event: event_name,
      properties: properties
    )

    Rails.logger.info("PosthogEventJob: #{event_name} - #{distinct_id} - #{properties}")
  end

end
