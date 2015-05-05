BabysittingTokens::Application.configure do
  config.cache_classes = true

  config.serve_static_files = true
  config.static_cache_control = "public, max-age=3600"

  config.eager_load = false

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_dispatch.show_exceptions = false

  config.action_controller.allow_forgery_protection    = false

  MandrillMailer.configure do |config|
    config.api_key = ENV['MANDRILL_API_TEST_KEY']
  end
  
  config.mandrill_mailer.default_url_options = { host: 'localhost:52662' }
  
  config.active_support.deprecation = :stderr
end
