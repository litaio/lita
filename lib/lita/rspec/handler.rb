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
            allow(robot).to receive(:send_message) do |target, *strings|
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

      def routes_http(http_method, path)
        HTTPRouteMatcher.new(self, http_method, path)
      end

      def does_not_route_http(http_method, path)
        HTTPRouteMatcher.new(self, http_method, path, invert: true)
      end
      alias_method :doesnt_route_http, :does_not_route_http
    end

    class RouteMatcher
      def initialize(context, message_body, invert: false)
        @context = context
        @message_body = message_body
        @method = invert ? :not_to : :to
      end

      def to(route)
        m = @method
        b = @message_body

        @context.instance_eval do
          allow(Authorization).to receive(:user_in_group?).and_return(true)
          expect_any_instance_of(described_class).public_send(m, receive(route))
          send_message(b)
        end
      end
    end

    class HTTPRouteMatcher
      def initialize(context, http_method, path, invert: false)
        @context = context
        @http_method = http_method
        @path = path
        @method = invert ? :not_to : :to
      end

      def to(route)
        m = @method
        h = @http_method
        p = @path

        @context.instance_eval do
          expect_any_instance_of(described_class).public_send(m, receive(route))
          env = Rack::MockRequest.env_for(p, method: h)
          robot.app.call(env)
        end
      end
    end
  end
end
