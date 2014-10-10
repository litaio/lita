require "simplecov"
require "coveralls"
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start { add_filter "/spec/" }

require "pry"
require "lita"
require "lita/cli"
require "lita/rspec"

Lita.version_3_compatibility_mode = false

RSpec.configure do |config|
  config.mock_with :rspec do |mocks_config|
    mocks_config.verify_doubled_constant_names = true
    mocks_config.verify_partial_doubles = true
  end

  config.before do
    logger = double("Lita:Logger").as_null_object
    allow(Lita).to receive(:logger).and_return(logger)
  end
end
