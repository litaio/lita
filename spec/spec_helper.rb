require "simplecov"
require "coveralls"
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start { add_filter "/spec/" }

require "pry"
require "lita/rspec"

RSpec.configure do |config|
  config.mock_with :rspec do |mocks_config|
    mocks_config.verify_doubled_constant_names = true
    mocks_config.verify_partial_doubles = true
  end
end
