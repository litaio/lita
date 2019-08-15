# frozen_string_literal: true

# Generate code coverage metrics, unless we're running a CI build that doesn't report the results.
unless ENV["CI"] && ENV["CC_TEST_REPORTER_ID"].nil?
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
