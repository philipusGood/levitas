source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

gem 'aasm'
gem 'active_record_union'
gem 'aws-sdk-s3'
gem "bootsnap", require: false
gem "devise", "~> 4.9", ">= 4.9.2"
gem "devise_invitable", "~> 2.0.0"
gem "flipper"
gem "flipper-active_record"
gem "haml-rails", "~> 2.0"
gem "html2haml"
gem "importmap-rails"
gem "image_processing", "~> 1.2"
gem "jbuilder"
gem "kaminari"
gem "letter_avatar"
gem "pretender"
gem "pg", "~> 1.5", ">= 1.5.3"
gem "puma", "~> 5.0"
gem "rails", "~> 7.0.4", ">= 7.0.4.2"
gem "rails-i18n"
gem "redis", "~> 5.3"
gem "sprockets-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "view_component"
gem 'wicked', '~> 2.0'
gem "jsonb_accessor"
gem "sendgrid-ruby"
gem "docusign_esign"
gem "jwt"
gem "typhoeus"
gem "posthog-ruby"
gem "bugsnag"
gem "finance"
gem "dotenv-rails"
gem "sidekiq", "~> 7.2"
gem "flipper-ui", "~> 1.3"
gem "maintenance_tasks", "~> 2.7"
gem 'faker'
gem "paranoia", "~> 2.2"
gem "sidekiq-cron"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "factory_bot_rails"
  gem "shoulda-matchers", "~> 5.0"
  gem "simplecov", require: false
  gem 'rspec-rails', '~> 6.0.0'
  gem 'pry-byebug'
end

group :development do
  gem "hotwire-livereload"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "database_cleaner"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "webdrivers"
end

gem "faraday", "~> 2.12"

gem "faraday-multipart", "~> 1.0"

gem "flipper-active_support_cache_store", "~> 1.3"
