begin
  require "rspec"
  require "rspec/expectations"
  require "rspec/mocks"
rescue LoadError
  abort I18n.t("lita.rspec.full_suite_required")
end

major, minor, _patch, *_pre = RSpec::Mocks::Version::STRING.split(/\./)
abort I18n.t("lita.rspec.mocks_expect_syntax_required") if major == "2" && minor.to_i < 14

require_relative "rspec/handler"

module Lita
  # Extras for +RSpec+ that facilitate the testing of Lita code.
  module RSpec
    class << self
      # Causes all interaction with Redis to use a test-specific namespace.
      # Clears Redis before each example. Stubs the logger to prevent log
      # messages from cluttering test output. Clears Lita's global
      # configuration.
      # @param base [Object] The class including the module.
      # @return [void]
      def included(base)
        base.class_eval do
          before do
            logger = double("Logger").as_null_object
            allow(Lita).to receive(:logger).and_return(logger)
            Lita.clear_config
          end
        end

        prepare_redis(base)
      end

      private

      # Set up Redis to use the test namespace and clear out before each
      # example.
      def prepare_redis(base)
        base.class_eval do
          before do
            stub_const("Lita::REDIS_NAMESPACE", "lita.test")
            keys = Lita.redis.keys("*")
            Lita.redis.del(keys) unless keys.empty?
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include Lita::RSpec, lita: true
  config.include Lita::RSpec::Handler, lita_handler: true
end
