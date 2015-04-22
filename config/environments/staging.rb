BabysittingTokens::Application.configure do

  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.serve_static_files = false

  config.assets.compress = true
  config.assets.js_compressor = :uglifier

  config.assets.compile = false

  config.assets.digest = true

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify
  
  MandrillMailer.configure do |config|
    config.api_key = ENV['MANDRILL_API_TEST_KEY']
  end

  config.mandrill_mailer.default_url_options = { host: 'http://babysitting-tokens-staging.herokuapp.com/' }
end