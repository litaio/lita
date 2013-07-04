begin
  require "rspec"
rescue LoadError
  abort "Lita::RSpec requires both RSpec::Mocks and RSpec::Expectations."
end

major, minor, patch, *pre = RSpec::Mocks::Version::STRING.split(/\./)
if major == "2" && minor.to_i < 14
  abort "RSpec::Mocks 2.14 or greater is required to use Lita::RSpec."
end

require "lita/rspec/handler"

module Lita
  module RSpec
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
