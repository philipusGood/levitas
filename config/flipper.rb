require 'active_support/cache'
require 'flipper/adapters/active_support_cache_store'

Flipper.configure do |config|
  config.use Flipper::Adapters::ActiveSupportCacheStore, Rails.cache, expires_in: 5.minutes
end
