begin
  require "rspec"
  require "rspec/expectations"
  require "rspec/mocks"
rescue LoadError
  abort I18n.t("lita.rspec.full_suite_required")
end

major, *_unused = RSpec::Core::Version::STRING.split(/\./)
abort I18n.t("lita.rspec.version_3_required") if major.to_i < 3

require "stringio"

require_relative "../lita"
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
          let(:registry) { Registry.new }

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

Lita.test_mode = true

RSpec.configure do |config|
  config.include Lita::RSpec, lita: true
  config.include Lita::RSpec::Handler, lita_handler: true
end
