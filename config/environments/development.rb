BabysittingTokens::Application.configure do
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: 'localhost:3000' }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Expands the lines which load the assets
  config.assets.debug = true

  config.eager_load = false
  
  MandrillMailer.configure do |config|
    config.api_key = ENV['MANDRILL_API_TEST_KEY']
  end

  config.mandrill_mailer.default_url_options = { host: 'localhost:3000' }
  
  CarrierWave.configure do |config|
    config.ignore_integrity_errors = false
    config.ignore_processing_errors = false
    config.ignore_download_errors = false
  end
  
end