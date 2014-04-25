require_relative "matchers/route_matcher"
require_relative "matchers/http_route_matcher"
require_relative "matchers/event_subscription_matcher"

module Lita
  module RSpec
    # Extras for +RSpec+ to facilitate testing Lita handlers.
    module Handler
      class << self
        # Sets up the RSpec environment to easily test Lita handlers.
        def included(base)
          base.class_eval do
            include Lita::RSpec
          end

          prepare_handlers(base)
          prepare_let_blocks(base)
          prepare_subject(base)
          prepare_robot(base)
        end

        private

        # Stub Lita.handlers.
        def prepare_handlers(base)
          base.class_eval do
            before { allow(Lita).to receive(:handlers).and_return([described_class]) }
          end
        end

        # Create common test objects.
        def prepare_let_blocks(base)
          base.class_eval do
            let(:robot) { Robot.new }
            let(:source) { Source.new(user: user) }
            let(:user) { User.create("1", name: "Test User") }
            let(:replies) { [] }
          end
        end

        # Stub Lita::Robot#send_messages.
        def prepare_robot(base)
          base.class_eval do
            before do
              [:send_messages, :send_message].each do |message|
                allow(robot).to receive(message) do |_target, *strings|
                  replies.concat(strings)
                end
              end
            end
          end
        end

        # Set up a working test subject.
        def prepare_subject(base)
          base.class_eval do
            subject { described_class.new(robot) }
            before { allow(described_class).to receive(:new).and_return(subject) }
          end
        end
      end

      # Sends a message to the robot.
      # @param body [String] The message to send.
      # @param as [Lita::User] The user sending the message.
      # @return [void]
      def send_message(body, as: user)
        message = if as == user
          Message.new(robot, body, source)
        else
          Message.new(robot, body, Source.new(user: as))
        end

        robot.receive(message)
      end

      # Sends a "command" message to the robot.
      # @param body [String] The message to send.
      # @param as [Lita::User] The user sending the message.
      # @return [void]
      def send_command(body, as: user)
        send_message("#{robot.mention_name}: #{body}", as: as)
      end

      # Starts a chat routing test chain, asserting that a message should
      # trigger a route.
      # @param message [String] The message that should trigger the route.
      # @return [Matchers::RouteMatcher] A {Matchers::RouteMatcher} that should have +to+
      #   called on it to complete the test.
      def routes(message)
        Matchers::RouteMatcher.new(self, message)
      end

      # Starts a chat routing test chain, asserting that a message should not
      # trigger a route.
      # @param message [String] The message that should not trigger the route.
      # @return [Matchers::RouteMatcher] A {Matchers::RouteMatcher} that should have +to+
      #   called on it to complete the test.
      def does_not_route(message)
        Matchers::RouteMatcher.new(self, message, expectation: false)
      end
      alias_method :doesnt_route, :does_not_route

      # Starts a chat routing test chain, asserting that a "command" message
      # should trigger a route.
      # @param message [String] The message that should trigger the route.
      # @return [Matchers::RouteMatcher] A {Matchers::RouteMatcher} that should have +to+
      #   called on it to complete the test.
      def routes_command(message)
        Matchers::RouteMatcher.new(self, "#{robot.mention_name}: #{message}")
      end

      # Starts a chat routing test chain, asserting that a "command" message
      # should not trigger a route.
      # @param message [String] The message that should not trigger the route.
      # @return [Matchers::RouteMatcher] A {Matchers::RouteMatcher} that should have +to+
      #   called on it to complete the test.
      def does_not_route_command(message)
        Matchers::RouteMatcher.new(self, "#{robot.mention_name}: #{message}", expectation: false)
      end
      alias_method :doesnt_route_command, :does_not_route_command

      # Starts an HTTP routing test chain, asserting that a request to the given
      # path with the given HTTP request method will trigger a route.
      # @param http_method [Symbol] The HTTP request method that should trigger
      #   the route.
      # @param path [String] The path URL component that should trigger the
      #   route.
      # @return [Matchers::HTTPRouteMatcher] A {Matchers::HTTPRouteMatcher} that should
      #   have +to+ called on it to complete the test.
      def routes_http(http_method, path)
        Matchers::HTTPRouteMatcher.new(self, http_method, path)
      end

      # Starts an HTTP routing test chain, asserting that a request to the given
      # path with the given HTTP request method will not trigger a route.
      # @param http_method [Symbol] The HTTP request method that should not
      #   trigger the route.
      # @param path [String] The path URL component that should not trigger the
      #   route.
      # @return [Matchers::HTTPRouteMatcher] A {Matchers::HTTPRouteMatcher} that should
      #   have +to+ called on it to complete the test.
      def does_not_route_http(http_method, path)
        Matchers::HTTPRouteMatcher.new(self, http_method, path, expectation: false)
      end
      alias_method :doesnt_route_http, :does_not_route_http

      # Starts an event subscription test chain, asserting that an event should
      # trigger the target method.
      # @param event_name [String, Symbol] The name of the event that should
      #   be triggered.
      # @return [Matchers::EventSubscriptionMatcher] A {Matchers::EventSubscriptionMatcher} that
      #   should have +to+ called on it to complete the test.
      def routes_event(event_name)
        Matchers::EventSubscriptionMatcher.new(self, event_name)
      end

      # Starts an event subscription test chain, asserting that an event should
      # not trigger the target method.
      # @param event_name [String, Symbol] The name of the event that should
      #   not be triggered.
      # @return [Matchers::EventSubscriptionMatcher] A {Matchers::EventSubscriptionMatcher} that
      #   should have +to+ called on it to complete the test.
      def does_not_route_event(event_name)
        Matchers::EventSubscriptionMatcher.new(self, event_name, expectation: false)
      end
      alias_method :doesnt_route_event, :does_not_route_event
    end
  end
end
