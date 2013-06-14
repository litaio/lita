module Lita
  module RSpec
    def self.included(base)
      base.class_eval do
        let(:robot) { Robot.new }

        before do
          allow(Lita).to receive(:handlers).and_return([described_class])
          stub_const("Lita::REDIS_NAMESPACE", "lita.test")
          keys = Lita.redis.keys("*")
          Lita.redis.del(keys) unless keys.empty?
        end
      end
    end

    def send_test_message(body)
      message = Message.new(robot, body, double("Source"))
      robot.receive(message)
    end

    def routes(message)
      RouteMatcher.new(self, message)
    end

    def does_not_route(message)
      RouteMatcher.new(self, message, invert: true)
    end
    alias_method :doesnt_route, :does_not_route
  end

  class RouteMatcher
    def initialize(context, message_body, invert: false)
      @context = context
      @message_body = message_body
      @method = invert ? :not_to : :to
    end

    def to(route)
      @context.expect_any_instance_of(
        @context.described_class
      ).public_send(@method, @context.receive(route))

      @context.send_test_message(@message_body)
    end
  end
end

RSpec.configure do |config|
  config.include Lita::RSpec, lita_handler: true
end
