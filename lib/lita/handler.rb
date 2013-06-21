module Lita
  class Handler
    extend Forwardable

    attr_reader :redis, :robot
    private :redis

    def_delegators :@message, :args, :command?, :scan, :user

    class Route < Struct.new(:pattern, :method_name, :command, :required_groups)
      alias_method :command?, :command
    end

    class << self
      def route(pattern, to: nil, command: false, restrict_to: nil)
        @routes ||= []
        required_groups = restrict_to.nil? ? nil : Array(restrict_to)
        @routes << Route.new(pattern, to, command, required_groups)
      end

      def dispatch(robot, message)
        instance = new(robot, message)

        @routes.each do |route|
          if route_applies?(route, instance)
            instance.public_send(
              route.method_name,
              matches_for_route(route, instance)
            )
          end
        end if defined?(@routes)
      end

      private

      def route_applies?(route, instance)
        # Message must match the pattern
        return unless route.pattern === instance.message_body

        # Message must be a command if the route requires a command
        return if route.command? && !instance.command?

        # User must be in auth group if route is restricted
        return if route.required_groups && route.required_groups.none? do |group|
          Authorization.user_in_group?(instance.user, group)
        end

        true
      end

      def matches_for_route(route, instance)
        instance.scan(route.pattern)
      end
    end

    def initialize(robot, message)
      @robot = robot
      @message = message
      @redis = Redis::Namespace.new(redis_namespace, redis: Lita.redis)
    end

    def reply(*strings)
      @robot.send_messages(@message.source, *strings)
    end

    def message_body
      @message.body
    end

    private

    def redis_namespace
      name = self.class.name.split("::").last.downcase
      "handlers:#{name}"
    end
  end
end
