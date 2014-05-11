require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require "simplecov"
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter
]
SimpleCov.start { add_filter "/spec/" }

require "pry"
require "lita"
require "lita/cli"
require "lita/rspec"

RSpec.configure do |config|
  config.mock_with :rspec do |mocks_config|
    mocks_config.verify_doubled_constant_names = true
    # Enable config option when a new rspec-mocks beta including this patch is released:
    # https://github.com/rspec/rspec-mocks/pull/615
    #
    # mocks_config.verify_partial_doubles = true
  end
end
