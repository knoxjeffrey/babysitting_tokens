# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'mandrill_mailer/offline'
require 'sidekiq/testing'
Sidekiq::Testing.inline!

OmniAuth.config.test_mode = true
omniauth_hash = { 'uid' => '12345',
                  'info' => {
                      'name' => 'Jeff Knox',
                      'email' => 'knoxjeffrey@outlook.com'
                  }
}
 
OmniAuth.config.add_mock(:facebook, omniauth_hash)

# I needed this for testing my mailers as they were using rails url helpers.  This prevents http://example.com being default root
Capybara.app_host = "http://localhost:52662"

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include FeatureSessionHelper, type: :feature #includes FeatureSessionHelper module only for feature tests
  
  # Use color in STDOUT
  config.color = true
    
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explictly tag your specs with their type, e.g.:
  #
  #     describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/v/3-0/docs
  config.infer_spec_type_from_file_location!
  
  # to allow CSS and Javascript to be loaded when we use save_and_open_page, the
  # development server must be running at localhost:3000 as specified below or
  # wherever you want. See original issue here:
  #https://github.com/jnicklas/capybara/pull/609
  # and final resolution here:
  #https://github.com/jnicklas/capybara/pull/958
  Capybara.asset_host = "http://localhost:3000"
end

