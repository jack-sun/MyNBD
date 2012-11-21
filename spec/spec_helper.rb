require 'spork'
require 'shoulda'
require 'database_cleaner'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require "rails/application"
  Spork.trap_method(Rails::Application, :reload_routes!)
  
  require File.expand_path("../../config/environment", __FILE__)
  require File.expand_path('../../lib/nbd/utils', __FILE__)
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.

  counter = -1
  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    #config.fixture_path = "#{::Rails.root}/spec/fixtures"

    #config.include Devise::TestHelpers, :type => :controller

    DatabaseCleaner.strategy = :truncation

    config.before(:suite) do
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    #config.use_transactional_fixtures = true

    config.after(:each) do
      counter += 1
      if counter > 9
        GC.enable
        GC.start
        GC.disable
        counter = 0
      end
    end

    config.after(:suite) do
      counter = 0
    end
  end

end
Spork.each_run do
  GC.disable
  require 'factory_girl'
  Factory.definition_file_paths = [
          File.join(Rails.root, 'spec', 'factories')
  ]
  Factory.find_definitions
  load_schema = lambda {
      # use db agnostic schema by default
      load "#{Rails.root.to_s}/db/schema.rb" 

      # if you use seeds uncomment next line
      # load "#{Rails.root.to_s}/db/seeds.rb"
      # ActiveRecord::Migrator.up('db/migrate') # use migrations
    }
  silence_stream(STDOUT, &load_schema) 
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

end
#Spork.each_run do
#require 'factory_girl_rails'
#Factory.factories.clear
#Factory.find_definitions.each do |location|
  #Dir["#{location}/**/*.rb"].each { |file| load file }
#end
#end
