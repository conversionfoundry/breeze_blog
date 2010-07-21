ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../../../../config/environment" unless defined?(Rails)
require 'rspec/rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Rspec.configure do |config|
  config.mock_with :rspec
  config.color_enabled = true
  
  config.before do
    # Mongoid.database.collections.each &:drop
  end
end
