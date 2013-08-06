module Lita
  # Base class for objects that add new behavior to Lita.
  class Handler
    extend Forwardable

    # A Redis::Namespace scoped to the handler.
    # @return [Redis::Namespace]
    attr_reader :redis

    # The running {Lita::Robot} instance.
    # @return [Lita::Robot]
    attr_reader :robot

    # A Struct representing a chat route defined by a handler.
    class Route < Struct.new(
      :pattern,
      :method_name,
      :command,
      :required_groups,
      :help
    )
      alias_method :command?, :command
    end

    class << self
      # Creates a chat route.
      # @param pattern [Regexp] A regular expression to match incoming messages
      #   against.
      # @param method [Symbol, String] The name of the method to trigger.
      # @param command [Boolean] Whether or not the message must be directed at
      #   the robot.
      # @param restrict_to [Array<Symbol, String>, nil] A list of authorization
      #   groups the user must be in to trigger the route.
      # @param help [Hash] A map of example invocations to descriptions.
      # @return [void]
      def route(pattern, method, command: false, restrict_to: nil, help: {})
        groups = restrict_to.nil? ? nil : Array(restrict_to)
        routes << Route.new(pattern, method, command, groups, help)
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
      # @return [void]
      def dispatch(robot, message)
        routes.select { |r| route_applies?(r, message, robot) }.each do |route|
          log_dispatch(route)

          begin
            new(robot).public_send(
              route.method_name,
              build_response(message, route)
            )
          rescue Exception => e
            log_dispatch_error(e)
            raise e if rspec_loaded?
          end
        end
      end

      # Creates a new {Lita::HTTPRoute} which is used to define an HTTP route
      # for the built-in web server.
      # @see Lita::HTTPRoute
      # @return [Lita::HTTPRoute] The new {Lita::HTTPRoute}.
      def http
        HTTPRoute.new(self)
      end

      # An array of all HTTP routes defined for the handler.
      # @return [Array<Lita::HTTPRoute>] The array of routes.
      def http_routes
        @http_routes ||= []
      end

      # The namespace for the handler, used for its configuration object and
      # Redis store. If the handler is an anonymous class, it must explicitly
      # define +self.name+.
      # @return [String] The handler's namespace.
      # @raise [RuntimeError] If +self.name+ is not defined.
      def namespace
        if name
          Util.underscore(name.split("::").last)
        else
          raise "Handlers that are anonymous classes must define self.name."
        end
      end

      private

      # Builds a response object for an incoming message.
      def build_response(message, route)
        Response.new(message, matches: message.match(route.pattern))
      end

      # Determines whether or not an incoming messages should trigger a route.
      def route_applies?(route, message, robot)
        # Message must match the pattern
        return unless route.pattern === message.body

        # Message must be a command if the route requires a command
        return if route.command? && !message.command?

        # Messages from self should be ignored to prevent infinite loops
        return if message.user.name == robot.name

        # User must be in auth group if route is restricted
        return unless authorized?(message.user, route.required_groups)

        true
      end

      # Checks if RSpec is loaded. If so, assume we are testing and let handler
      # exceptions bubble up.
      def rspec_loaded?
        defined?(::RSpec)
      end

      # Checks if the user is authorized to at least one of the given groups.
      def authorized?(user, required_groups)
        required_groups.nil? || required_groups.any? do |group|
          Authorization.user_in_group?(user, group)
        end
      end

      # Logs the dispatch of message.
      def log_dispatch(route)
        Lita.logger.debug <<-LOG.chomp
Dispatching message to #{self}##{route.method_name}.
LOG
      end

      def log_dispatch_error(e)
        Lita.logger.error <<-ERROR.chomp
#{name} crashed. The exception was:
#{e.message}
#{e.backtrace.join("\n")}
ERROR
      end
    end

    # @param robot [Lita::Robot] The currently running robot.
    def initialize(robot)
      @robot = robot
      @redis = Redis::Namespace.new(redis_namespace, redis: Lita.redis)
    end

    # Creates a new +Faraday::Connection+ for making HTTP requests.
    # @param options [Hash] A set of options passed on to Faraday.
    # @yield [builder] A Faraday builder object for adding middleware.
    # @return [Faraday::Connection] The new connection object.
    def http(options = {}, &block)
      options = default_faraday_options.merge(options)
      Faraday::Connection.new(nil, options, &block)
    end

    private

    # Default options for new Faraday connections. Sets the user agent to the
    # current version of Lita.
    def default_faraday_options
      { headers: { "User-Agent" => "Lita v#{VERSION}" } }
    end

    # The handler's namespace for Redis.
    def redis_namespace
      "handlers:#{self.class.namespace}"
    end
  end
end
