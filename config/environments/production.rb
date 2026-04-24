require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Self-hosted: no master key needed (no encrypted credentials in use)
  # config.require_master_key = true

  # Serve static files directly from Puma (no Nginx in front)
  config.public_file_server.enabled = true

  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true
  # config/environments/production.rb
  # config.asset_host = 'https://levitas.herokuapp.com'

  # Self-hosted: no external asset host

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  # config.action_dispatch.x_sendfile_header = "X-Accel-Redirect" # for NGINX

  # Store uploaded files on local disk (self-hosted, no S3)
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain.
  # config.action_cable.mount_path = nil
  # config.action_cable.url = "wss://example.com/cable"
  # config.action_cable.allowed_request_origins = [ "http://example.com", /http:\/\/example.*/ ]

  # Self-hosted on LAN: no SSL needed
  config.force_ssl = false

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  config.active_job.queue_adapter     = :sidekiq
  # config.active_job.queue_name_prefix = "levitas_production"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new "app-name")

  # Always log to stdout in Docker
  logger           = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger    = ActiveSupport::TaggedLogging.new(logger)

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "localhost:3000") }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: 'smtp.sendgrid.net',
    port: '587',
    authentication: :plain,
    user_name: 'apikey',
    password: ENV.fetch('SENDGRID_API_KEY', ''),
    domain: ENV.fetch("APP_HOST", "localhost:3000"),
    enable_starttls_auto: true
  }
end
