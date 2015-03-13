module Lita
  class Handler
    # A handler mixin that provides the methods necessary for responding to chat messages.
    # @since 4.0.0
    module ChatRouter
      # Includes common handler methods in any class that includes {ChatRouter}.
      def self.extended(klass)
        klass.send(:include, Common)
      end

      # A Struct representing a chat route defined by a handler.
      class Route < Struct.new(
        :pattern,
        :callback,
        :command,
        :required_groups,
        :help,
        :extensions
      )
        alias_method :command?, :command
      end

      # @overload route(pattern, method_name, **options)
      #   Creates a chat route.
      #   @param pattern [Regexp] A regular expression to match incoming messages against.
      #   @param method_name [Symbol, String] The name of the instance method to trigger.
      #   @param command [Boolean] Whether or not the message must be directed at the robot.
      #   @param restrict_to [Array<Symbol, String>, nil] An optional list of authorization
      #     groups the user must be in to trigger the route.
      #   @param help [Hash] An optional map of example invocations to descriptions.
      #   @param options [Hash] Aribtrary additional data that can be used by Lita extensions.
      #   @return [void]
      # @overload route(pattern, **options)
      #   Creates a chat route.
      #   @param pattern [Regexp] A regular expression to match incoming messages against.
      #   @param command [Boolean] Whether or not the message must be directed at the robot.
      #   @param restrict_to [Array<Symbol, String>, nil] An optional list of authorization
      #     groups the user must be in to trigger the route.
      #   @param help [Hash] An optional map of example invocations to descriptions.
      #   @param options [Hash] Aribtrary additional data that can be used by Lita extensions.
      #   @yield The body of the route's callback.
      #   @return [void]
      #   @since 4.0.0
      def route(pattern, method_name = nil, **options, &block)
        options = default_route_options.merge(options)
        options[:restrict_to] = options[:restrict_to].nil? ? nil : Array(options[:restrict_to])
        routes << Route.new(
          pattern,
          Callback.new(method_name || block),
          options.delete(:command),
          options.delete(:restrict_to),
          options.delete(:help),
          options
        )
      end

      # A list of chat routes defined by the handler.
      # @return [Array<Lita::Handler::Route>]
      def routes
        @routes ||= []
      end

      # The main entry point for the handler at runtime. Checks if the message
      # matches any of the routes and invokes the route's method if it does.
      # Called by {Lita::Robot#receive}.
      # @param robot [Lita::Robot] The currently running robot.
      # @param message [Lita::Message] The incoming message.
      # @return [Boolean] Whether or not the message matched any routes.
      def dispatch(robot, message)
        routes.map do |route|
          next unless route_applies?(route, message, robot)
          log_dispatch(route)
          dispatch_to_route(route, robot, message)
          true
        end.any?
      end

      # Dispatch directly to a {Route}, ignoring route conditions.
      # @param route [Route] The route to invoke.
      # @param robot [Lita::Robot] The currently running robot.
      # @param message [Lita::Message] The incoming message.
      # @return [void]
      # @since 3.3.0
      def dispatch_to_route(route, robot, message)
        response = Response.new(message, route.pattern)
        robot.hooks[:trigger_route].each { |hook| hook.call(response: response, route: route) }
        handler = new(robot)
        route.callback.call(handler, response)
      rescue Exception => e
        log_dispatch_error(e)
        robot.config.robot.error_handler.call(e)
        raise e if Lita.test_mode?
      end

      private

      # The default options for every chat route.
      def default_route_options
        {
          command: false,
          restrict_to: nil,
          help: {}
        }
      end

      # Determines whether or not an incoming messages should trigger a route.
      def route_applies?(route, message, robot)
        RouteValidator.new(self, route, message, robot).call
      end

      # Logs the dispatch of message.
      def log_dispatch(route)
        Lita.logger.debug I18n.t(
          "lita.handler.dispatch",
          handler: name,
          method: route.callback.method_name || "(block)"
        )
      end

      # Logs an error encountered during dispatch.
      def log_dispatch_error(e)
        Lita.logger.error I18n.t(
          "lita.handler.exception",
          handler: name,
          message: e.message,
          backtrace: e.backtrace.join("\n")
        )
      end
    end
  end
end
