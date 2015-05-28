BabysittingTokens::Application.configure do

  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.serve_static_files = true

  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass
  config.assets.debug = false

  config.assets.compile = true

  config.assets.digest = true

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify
  
  config.log_level = :info
  
  MandrillMailer.configure do |config|
    config.api_key = ENV['MANDRILL_APIKEY']
  end
  
  config.mandrill_mailer.default_url_options = { host: "babysitting-tokens.herokuapp.com" }
  
end