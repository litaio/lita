# frozen_string_literal: true

# Generate code coverage metrics outside CI.
unless ENV["CI"]
  require "simplecov"
  SimpleCov.start { add_filter "/spec/" }
end

require "pry"
require "lita/rspec"

RSpec.configure do |config|
  config.mock_with :rspec do |mocks_config|
    mocks_config.verify_doubled_constant_names = true
    mocks_config.verify_partial_doubles = true
  end
end
