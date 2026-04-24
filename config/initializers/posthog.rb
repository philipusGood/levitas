Rails.logger.info "Initializing PostHog in environment: #{Rails.env}"

api_key = Rails.application.credentials.dig(:posthog, :api_key)
Rails.logger.info "PostHog API Key: #{api_key.present? ? 'Loaded' : 'Missing'}"

if api_key.present?
  $posthog = PostHog::Client.new(
    api_key: api_key,
    host: 'https://us.i.posthog.com',
    on_error: Proc.new { |status, msg| Rails.logger.error(msg) }
  )
else
  Rails.logger.error("PostHog API key is missing in environment: #{Rails.env}")
end