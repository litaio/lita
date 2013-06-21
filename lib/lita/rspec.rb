module Lita
  module RSpec
    def self.included(base)
      base.class_eval do
        let(:robot) { Robot.new }
        let(:source) { Source.new(user) }
        let(:user) { User.new("1", name: "Test User") }

        before do
          allow(Lita).to receive(:handlers).and_return([described_class])
          stub_const("Lita::REDIS_NAMESPACE", "lita.test")
          keys = Lita.redis.keys("*")
          Lita.redis.del(keys) unless keys.empty?
          allow(robot).to receive(:send_messages)
        end
      end
    end

    def expect_reply(argument, invert: false)
      method = invert ? :not_to : :to
      expect(robot).public_send(
        method,
        receive(:send_messages).with(source, argument)
      )
    end

    def expect_no_reply(argument)
      expect_reply(argument, invert: true)
    end

    def send_test_message(body)
      message = Message.new(robot, body, source)
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
  config.include Lita::RSpec, lita: true
end
