Bugsnag.configure do |config|
  config.api_key = Rails.application.credentials&.bugsnag&.api_key || ENV['BUGSNAG_API_KEY']
  config.enabled_release_stages = ['production', 'staging']
end
