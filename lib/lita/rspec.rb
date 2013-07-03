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
