module Lita
  # Base class for objects that add new scheduled behavior to Lita.
  class Scheduler

    # A Redis::Namespace scoped to the scheduler.
    # @return [Redis::Namespace]
    attr_reader :redis

    # The running {Lita::Robot} instance.
    # @return [Lita::Robot]
    attr_reader :robot

    # A Struct representing a cron job.
    class Job < Struct.new(
      :type,
      :field,
      :method_name,
      :help
    )
    end

    class << self
      [:schedule, :cron, :at, :every].each do |type|
        define_method(type) do |field, method|
          jobs << Job.new(type, field, method)
        end
      end

      def jobs
        @jobs ||= []
      end

      # Register scheduled jobs to robot.scheduler
      def start(robot)
        jobs.each do |job|
          scheduler = new(robot)
          unless scheduler.respond_to?(job.method_name)
            raise "you should implement #{self.name}##{job.method_name}"
          end

          robot.scheduler.public_send(job.type, job.field) do
            scheduler.public_send(job.method_name)
          end
        end
      end

      # The namespace for the scheduler, used for its configuration object and
      # Redis store. If the scheduler is an anonymous class, it must explicitly
      # define +self.name+.
      # @return [String] The scheduler's namespace.
      # @raise [RuntimeError] If +self.name+ is not defined.
      def namespace
        if name
          Util.underscore(name.split("::").last)
        else
          raise "schedulers that are anonymous classes must define self.name."
        end
      end

      private

      # Checks if RSpec is loaded. If so, assume we are testing and let scheduler
      # exceptions bubble up.
      def rspec_loaded?
        defined?(::RSpec)
      end
    end

    # @param robot [Lita::Robot] The currently running robot.
    def initialize(robot)
      @robot = robot
      @redis = Redis::Namespace.new(redis_namespace, redis: Lita.redis)
    end

    # Send message
    def send_messages(room: nil, user: nil, message: nil)
      raise ArgumentError.new("message is required.") if message.nil?
      target = Source.new(user: user, room: room)
      robot.send_messages(target, message)
    end
    alias_method :send_message, :send_messages

    private

    # The scheduler's namespace for Redis.
    def redis_namespace
      "schedulers:#{self.class.namespace}"
    end
  end
end
