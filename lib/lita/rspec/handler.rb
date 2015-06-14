require_relative "matchers/chat_route_matcher"
require_relative "matchers/http_route_matcher"
require_relative "matchers/event_route_matcher"
require_relative "matchers/deprecated"

module Lita
  module RSpec
    # Extras for +RSpec+ to facilitate testing Lita handlers.
    module Handler
      include Matchers::ChatRouteMatcher
      include Matchers::HTTPRouteMatcher
      include Matchers::EventRouteMatcher

      class << self
        # Sets up the RSpec environment to easily test Lita handlers.
        def included(base)
          base.send(:include, Lita::RSpec)

          prepare_handlers(base)
          prepare_let_blocks(base)
          prepare_subject(base)
          prepare_robot(base)
        end

        private

        # Stub Lita.handlers.
        def prepare_handlers(base)
          base.class_eval do
            before do
              handlers = Set.new(
                [described_class] + Array(base.metadata[:additional_lita_handlers])
              )

              if Lita.version_3_compatibility_mode?
                allow(Lita).to receive(:handlers).and_return(handlers)
              else
                handlers.each do |handler|
                  registry.register_handler(handler)
                end
              end
            end
          end
        end

        # Create common test objects.
        def prepare_let_blocks(base)
          base.class_eval do
            let(:robot) { Robot.new(registry) }
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
      # @param as [String] The room where the message is received from.
      # @return [void]
      def send_message(body, as: user, from: nil)
        Message.new(robot, body, Source.new(user: as, room: from))

        robot.receive(message)
      end

      # Sends a "command" message to the robot.
      # @param body [String] The message to send.
      # @param as [Lita::User] The user sending the message.
      # @return [void]
      def send_command(body, as: user)
        send_message("#{robot.mention_name}: #{body}", as: as)
      end

      # Returns a Faraday connection hooked up to the currently running robot's Rack app.
      # @return [Faraday::Connection] The connection.
      # @since 4.0.0
      def http
        begin
          require "rack/test"
        rescue LoadError
          raise LoadError, I18n.t("lita.rspec.rack_test_required")
        end unless Rack.const_defined?(:Test)

        Faraday::Connection.new { |c| c.adapter(:rack, robot.app) }
      end

      # Starts a chat routing test chain, asserting that a message should
      # trigger a route.
      # @param message [String] The message that should trigger the route.
      # @return [Matchers::Deprecated] A {Matchers::Deprecated} that should have +to+
      #   called on it to complete the test.
      # @deprecated Will be removed in Lita 5.0. Use +is_expected.to route+ instead.
      def routes(message)
        STDERR.puts I18n.t(
          "lita.rspec.matcher_deprecated",
          old_method: "routes",
          new_method: "is_expected.to route",
        )
        Matchers::Deprecated.new(self, :route, true, message)
      end

      # Starts a chat routing test chain, asserting that a message should not
      # trigger a route.
      # @param message [String] The message that should not trigger the route.
      # @return [Matchers::Deprecated] A {Matchers::Deprecated} that should have +to+
      #   called on it to complete the test.
      # @deprecated Will be removed in Lita 5.0. Use +is_expected.not_to route+ instead.
      def does_not_route(message)
        STDERR.puts I18n.t(
          "lita.rspec.matcher_deprecated",
          old_method: "does_not_route",
          new_method: "is_expected.not_to route",
        )
        Matchers::Deprecated.new(self, :route, false, message)
      end
      alias_method :doesnt_route, :does_not_route

      # Starts a chat routing test chain, asserting that a "command" message
      # should trigger a route.
      # @param message [String] The message that should trigger the route.
      # @return [Matchers::Deprecated] A {Matchers::Deprecated} that should have +to+
      #   called on it to complete the test.
      # @deprecated Will be removed in Lita 5.0. Use +is_expected.to route_command+ instead.
      def routes_command(message)
        STDERR.puts I18n.t(
          "lita.rspec.matcher_deprecated",
          old_method: "routes_command",
          new_method: "is_expected.to route_command",
        )
        Matchers::Deprecated.new(self, :route_command, true, message)
      end

      # Starts a chat routing test chain, asserting that a "command" message
      # should not trigger a route.
      # @param message [String] The message that should not trigger the route.
      # @return [Matchers::Deprecated] A {Matchers::Deprecated} that should have +to+
      #   called on it to complete the test.
      # @deprecated Will be removed in Lita 5.0. Use +is_expected.not_to route_command+ instead.
      def does_not_route_command(message)
        STDERR.puts I18n.t(
          "lita.rspec.matcher_deprecated",
          old_method: "does_not_route_command",
          new_method: "is_expected.not_to route_command",
        )
        Matchers::Deprecated.new(self, :route_command, false, message)
      end
      alias_method :doesnt_route_command, :does_not_route_command

      # Starts an HTTP routing test chain, asserting that a request to the given
      # path with the given HTTP request method will trigger a route.
      # @param http_method [Symbol] The HTTP request method that should trigger
      #   the route.
      # @param path [String] The path URL component that should trigger the
      #   route.
      # @return [Matchers::Deprecated] A {Matchers::Deprecated} that should
      #   have +to+ called on it to complete the test.
      # @deprecated Will be removed in Lita 5.0. Use +is_expected.to route_http+ instead.
      def routes_http(http_method, path)
        STDERR.puts I18n.t(
          "lita.rspec.matcher_deprecated",
          old_method: "routes_http",
          new_method: "is_expected.to route_http",
        )
        Matchers::Deprecated.new(self, :route_http, true, http_method, path)
      end

      # Starts an HTTP routing test chain, asserting that a request to the given
      # path with the given HTTP request method will not trigger a route.
      # @param http_method [Symbol] The HTTP request method that should not
      #   trigger the route.
      # @param path [String] The path URL component that should not trigger the
      #   route.
      # @return [Matchers::Deprecated] A {Matchers::Deprecated} that should
      #   have +to+ called on it to complete the test.
      # @deprecated Will be removed in Lita 5.0. Use +is_expected.not_to route_http+ instead.
      def does_not_route_http(http_method, path)
        STDERR.puts I18n.t(
          "lita.rspec.matcher_deprecated",
          old_method: "does_not_route_http",
          new_method: "is_expected.not_to route_http",
        )
        Matchers::Deprecated.new(self, :route_http, false, http_method, path)
      end
      alias_method :doesnt_route_http, :does_not_route_http

      # Starts an event subscription test chain, asserting that an event should
      # trigger the target method.
      # @param event_name [String, Symbol] The name of the event that should
      #   be triggered.
      # @return [Matchers::Deprecated] A {Matchers::Deprecated} that
      #   should have +to+ called on it to complete the test.
      # @deprecated Will be removed in Lita 5.0. Use +is_expected.to route_event+ instead.
      def routes_event(event_name)
        STDERR.puts I18n.t(
          "lita.rspec.matcher_deprecated",
          old_method: "routes_event",
          new_method: "is_expected.to route_event",
        )
        Matchers::Deprecated.new(self, :route_event, true, event_name)
      end

      # Starts an event subscription test chain, asserting that an event should
      # not trigger the target method.
      # @param event_name [String, Symbol] The name of the event that should
      #   not be triggered.
      # @return [Matchers::Deprecated] A {Matchers::Deprecated} that
      #   should have +to+ called on it to complete the test.
      # @deprecated Will be removed in Lita 5.0. Use +is_expected.not_to route_event+ instead.
      def does_not_route_event(event_name)
        STDERR.puts I18n.t(
          "lita.rspec.matcher_deprecated",
          old_method: "does_not_route_event",
          new_method: "is_expected.not_to route_event",
        )
        Matchers::Deprecated.new(self, :route_event, false, event_name)
      end
      alias_method :doesnt_route_event, :does_not_route_event
    end
  end
end
