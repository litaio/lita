module Lita
  class Handler
    extend Forwardable

    attr_reader :redis, :robot
    private :redis

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
      attr_reader :routes

      def route(pattern, method, command: false, restrict_to: nil, help: {})
        groups = restrict_to.nil? ? nil : Array(restrict_to)
        routes << Route.new(pattern, method, command, groups, help)
      end

      def routes
        @routes ||= []
      end

      def dispatch(robot, message)
        routes.each do |route|
          if route_applies?(route, message)
            new(robot).public_send(route.method_name, Response.new(
              message,
              matches: message.match(route.pattern)
            ))
          end
        end
      end

      def http
        HTTPRoute.new(self)
      end

      def http_routes
        @http_routes ||= []
      end

      def namespace
        if name
          name.split("::").last.downcase
        else
          raise "Handlers that are anonymous classes must define self.name."
        end
      end

      private

      def route_applies?(route, message)
        # Message must match the pattern
        return unless route.pattern === message.body

        # Message must be a command if the route requires a command
        return if route.command? && !message.command?

        # User must be in auth group if route is restricted
        return if route.required_groups && route.required_groups.none? do |group|
          Authorization.user_in_group?(message.user, group)
        end

        true
      end
    end

    def initialize(robot)
      @robot = robot
      @redis = Redis::Namespace.new(redis_namespace, redis: Lita.redis)
    end

    private

    def redis_namespace
      "handlers:#{self.class.namespace}"
    end
  end
end
