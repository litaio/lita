begin
  require "rspec"
  require "rspec/expectations"
  require "rspec/mocks"
rescue LoadError
  abort "Lita::RSpec requires both RSpec::Mocks and RSpec::Expectations."
end

major, minor, patch, *pre = RSpec::Mocks::Version::STRING.split(/\./)
if major == "2" && minor.to_i < 14
  abort "RSpec::Mocks 2.14 or greater is required to use Lita::RSpec."
end

require "lita/rspec/handler"

module Lita
  # Extras for +RSpec+ that facilitate the testing of Lita code.
  module RSpec
    # Causes all interaction with Redis to use a test-specific namespace. Clears
    # Redis before each example. Stubs the logger to prevent log messages from
    # cluttering test output. Clears Lita's global configuration.
    # @param base [Object] The class including the module.
    # @return [void]
    def self.included(base)
      base.class_eval do
        before do
          stub_const("Lita::REDIS_NAMESPACE", "lita.test")
          keys = Lita.redis.keys("*")
          Lita.redis.del(keys) unless keys.empty?
          logger = double("Logger").as_null_object
          allow(Lita).to receive(:logger).and_return(logger)
          Lita.clear_config
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Lita::RSpec, lita: true
  config.include Lita::RSpec::Handler, lita_handler: true
end
