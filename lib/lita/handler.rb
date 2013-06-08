module Lita
  class Handler
    extend Forwardable

    attr_reader :message, :redis
    private :redis

    def_delegators :@robot, :say

    class Route < Struct.new(:pattern, :method_name, :command)
      alias_method :command?, :command
    end

    class << self
      def route(pattern, to: nil, command: false)
        @routes ||= []
        @routes << Route.new(pattern, to, command)
      end

      def dispatch(robot, message)
        instance = new(robot, message)

        @routes.each do |route|
          if route_applies?(route, instance)
            instance.public_send(
              route[:method_name],
              route_matches(route, instance)
            )
          end
        end
      end

      private

      def route_applies?(route, instance)
        if route.pattern === instance.message
          if route.command?
            return instance.command?
          else
            return true
          end
        end

        false
      end

      def route_matches(route, instance)
        instance.message.scan(route.pattern)
      end
    end

    def initialize(robot, message)
      @robot = robot
      @message = message
      @command = !!@message.sub!(/^\s*@?#{@robot.name}[:,]?\s*/, "")
      @redis = Redis::Namespace.new(redis_namespace, redis: Lita.redis)
    end

    def command?
      @command
    end

    private

    def redis_namespace
      name = self.class.name.split("::").last.downcase
      "handlers:#{name}"
    end

    def args
      begin
        command, *args = message.shellsplit
      rescue ArgumentError
        command, *args =
          message.split(/\s+/).map(&:shellescape).join(" ").shellsplit
      end

      args
    end
  end
end
