module Lita
  module RSpec
    module Matchers
      module DeprecatedMethods
        # Starts a chat routing test chain, asserting that a message should
        # trigger a route.
        # @param message [String] The message that should trigger the route.
        # @return [Deprecated] A {Deprecated} that should have +to+
        #   called on it to complete the test.
        # @deprecated Will be removed in Lita 5.0. Use +is_expected.to route+ instead.
        def routes(message)
          STDERR.puts I18n.t(
            "lita.rspec.matcher_deprecated",
            old_method: "routes",
            new_method: "is_expected.to route",
          )
          Deprecated.new(self, :route, true, message)
        end

        # Starts a chat routing test chain, asserting that a message should not
        # trigger a route.
        # @param message [String] The message that should not trigger the route.
        # @return [Deprecated] A {Deprecated} that should have +to+
        #   called on it to complete the test.
        # @deprecated Will be removed in Lita 5.0. Use +is_expected.not_to route+ instead.
        def does_not_route(message)
          STDERR.puts I18n.t(
            "lita.rspec.matcher_deprecated",
            old_method: "does_not_route",
            new_method: "is_expected.not_to route",
          )
          Deprecated.new(self, :route, false, message)
        end
        alias_method :doesnt_route, :does_not_route

        # Starts a chat routing test chain, asserting that a "command" message
        # should trigger a route.
        # @param message [String] The message that should trigger the route.
        # @return [Deprecated] A {Deprecated} that should have +to+
        #   called on it to complete the test.
        # @deprecated Will be removed in Lita 5.0. Use +is_expected.to route_command+ instead.
        def routes_command(message)
          STDERR.puts I18n.t(
            "lita.rspec.matcher_deprecated",
            old_method: "routes_command",
            new_method: "is_expected.to route_command",
          )
          Deprecated.new(self, :route_command, true, message)
        end

        # Starts a chat routing test chain, asserting that a "command" message
        # should not trigger a route.
        # @param message [String] The message that should not trigger the route.
        # @return [Deprecated] A {Deprecated} that should have +to+
        #   called on it to complete the test.
        # @deprecated Will be removed in Lita 5.0. Use +is_expected.not_to route_command+ instead.
        def does_not_route_command(message)
          STDERR.puts I18n.t(
            "lita.rspec.matcher_deprecated",
            old_method: "does_not_route_command",
            new_method: "is_expected.not_to route_command",
          )
          Deprecated.new(self, :route_command, false, message)
        end
        alias_method :doesnt_route_command, :does_not_route_command

        # Starts an HTTP routing test chain, asserting that a request to the given
        # path with the given HTTP request method will trigger a route.
        # @param http_method [Symbol] The HTTP request method that should trigger
        #   the route.
        # @param path [String] The path URL component that should trigger the
        #   route.
        # @return [Deprecated] A {Deprecated} that should
        #   have +to+ called on it to complete the test.
        # @deprecated Will be removed in Lita 5.0. Use +is_expected.to route_http+ instead.
        def routes_http(http_method, path)
          STDERR.puts I18n.t(
            "lita.rspec.matcher_deprecated",
            old_method: "routes_http",
            new_method: "is_expected.to route_http",
          )
          Deprecated.new(self, :route_http, true, http_method, path)
        end

        # Starts an HTTP routing test chain, asserting that a request to the given
        # path with the given HTTP request method will not trigger a route.
        # @param http_method [Symbol] The HTTP request method that should not
        #   trigger the route.
        # @param path [String] The path URL component that should not trigger the
        #   route.
        # @return [Deprecated] A {Deprecated} that should
        #   have +to+ called on it to complete the test.
        # @deprecated Will be removed in Lita 5.0. Use +is_expected.not_to route_http+ instead.
        def does_not_route_http(http_method, path)
          STDERR.puts I18n.t(
            "lita.rspec.matcher_deprecated",
            old_method: "does_not_route_http",
            new_method: "is_expected.not_to route_http",
          )
          Deprecated.new(self, :route_http, false, http_method, path)
        end
        alias_method :doesnt_route_http, :does_not_route_http

        # Starts an event subscription test chain, asserting that an event should
        # trigger the target method.
        # @param event_name [String, Symbol] The name of the event that should
        #   be triggered.
        # @return [Deprecated] A {Deprecated} that
        #   should have +to+ called on it to complete the test.
        # @deprecated Will be removed in Lita 5.0. Use +is_expected.to route_event+ instead.
        def routes_event(event_name)
          STDERR.puts I18n.t(
            "lita.rspec.matcher_deprecated",
            old_method: "routes_event",
            new_method: "is_expected.to route_event",
          )
          Deprecated.new(self, :route_event, true, event_name)
        end

        # Starts an event subscription test chain, asserting that an event should
        # not trigger the target method.
        # @param event_name [String, Symbol] The name of the event that should
        #   not be triggered.
        # @return [Deprecated] A {Deprecated} that
        #   should have +to+ called on it to complete the test.
        # @deprecated Will be removed in Lita 5.0. Use +is_expected.not_to route_event+ instead.
        def does_not_route_event(event_name)
          STDERR.puts I18n.t(
            "lita.rspec.matcher_deprecated",
            old_method: "does_not_route_event",
            new_method: "is_expected.not_to route_event",
          )
          Deprecated.new(self, :route_event, false, event_name)
        end
        alias_method :doesnt_route_event, :does_not_route_event
      end

      # Lita 3 versions of the routing  matchers.
      # @deprecated Will be removed in Lita 5.0. Use the +is_expected+ forms instead.
      class Deprecated
        # @param context [RSpec::ExampleGroup] The example group where the matcher was called.
        # @param new_method_name [String, Symbol] The method that should be used instead.
        # @param positive [Boolean] Whether or not a positive expectation is being made.
        def initialize(context, new_method_name, positive, *args)
          @context = context
          @new_method_name = new_method_name
          @expectation_method_name = positive ? :to : :not_to
          @args = args

          @context.instance_exec do
            allow_any_instance_of(Authorization).to receive(:user_in_group?).and_return(true)
          end
        end

        # Sets an expectation that the previously supplied message will route to the provided
        # method.
        # @param method_name [String, Symbol] The name of the method that should be routed to.
        def to(method_name)
          emn = @expectation_method_name
          matcher = @context.public_send(@new_method_name, *@args)
          matcher.to(method_name)

          @context.instance_exec do
            is_expected.public_send(emn, matcher)
          end
        end
      end
    end
  end
end
