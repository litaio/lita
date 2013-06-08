require "lita/adapters/test"

module Lita
  module RSpec
    def self.included(base)
      base.class_eval do
        let(:robot) { Robot.new }

        before do
          stub_const("Lita::REDIS_NAMESPACE", "lita.test")
          keys = Lita.redis.keys("*")
          Lita.redis.del(keys) unless keys.empty?
        end
      end
    end

    def send_test_message(message)
      robot.receive(message)
    end

    def routes(message)
      RouteMatcher.new(self, message)
    end
  end

  class RouteMatcher < Struct.new(:context, :message)
    def to(route)
      context.expect_any_instance_of(
        context.described_class
      ).to context.receive(route)

      context.send_test_message(message)
    end
  end
end

RSpec.configure do |config|
  config.include Lita::RSpec, lita_handler: true
end
