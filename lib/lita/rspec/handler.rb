module Lita
  module RSpec
    module Handler
      def self.included(base)
        base.class_eval do
          include Lita::RSpec

          let(:robot) { Robot.new }
          let(:source) { Source.new(user) }
          let(:user) { User.create("1", name: "Test User") }
          let(:replies) { [] }

          subject { described_class.new(robot) }

          before do
            allow(Lita).to receive(:handlers).and_return([described_class])
            allow(robot).to receive(:send_messages) do |target, *strings|
              replies.concat(strings)
            end
          end
        end
      end

      def send_message(body, as: user)
        message = if as == user
          Message.new(robot, body, source)
        else
          Message.new(robot, body, Source.new(as))
        end

        robot.receive(message)
      end

      def send_command(body, as: user)
        send_message("#{robot.mention_name}: #{body}", as: as)
      end

      def routes(message)
        RouteMatcher.new(self, message)
      end

      def does_not_route(message)
        RouteMatcher.new(self, message, invert: true)
      end
      alias_method :doesnt_route, :does_not_route

      def routes_command(message)
        RouteMatcher.new(self, "#{robot.mention_name}: #{message}")
      end

      def does_not_route_command(message)
        RouteMatcher.new(self, "#{robot.mention_name}: #{message}", invert: true)
      end
      alias_method :doesnt_route_command, :does_not_route_command
    end

    class RouteMatcher
      def initialize(context, message_body, invert: false)
        @context = context
        @message_body = message_body
        @method = invert ? :not_to : :to
      end

      def to(route)
        @context.allow(Authorization).to @context.receive(
          :user_in_group?
        ).and_return(true)
        @context.expect_any_instance_of(
          @context.described_class
        ).public_send(@method, @context.receive(route))

        @context.send_message(@message_body)
      end
    end
  end
end
