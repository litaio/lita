require "forwardable"
require "shellwords"

module Lita
  class Handler
    class << self
      attr_accessor :listeners, :commands

      def listener(method, pattern)
        @listeners ||= []
        @listeners << { method: method, pattern: pattern }
      end

      def command(method, pattern)
        @commands ||= []
        @commands << { method: method, pattern: pattern }
      end

      def dispatch(robot, message)
        dispatch_to_commands(robot, message)
        dispatch_to_listeners(robot, message)
      end

      private

      def dispatch_to_commands(robot, message)
        command_name, *args = message.command_with_args(robot.name)

        return unless command_name

        commands.each do |command|
          unless message.matches(command[:pattern]).empty?
            new(robot).public_send(command[:method], message)
          end
        end
      end

      def dispatch_to_listeners(robot, message)
        listeners.each do |listener|
          unless message.matches(listener[:pattern]).empty?
            new(robot).public_send(listener[:method], message)
          end
        end
      end
    end

    extend Forwardable

    attr_reader :robot

    def_delegators :robot, :say

    def initialize(robot)
      @robot = robot
    end

    private

    def storage
      @storage ||= robot.storage_for_handler(storage_key)
    end

    def storage_key
      key = self.class.name

      unless key
        raise MissingStorageKeyError.new(
          'If a Lita handler is an anonymous class, it must implement ' +
            '#storage_key, which must return a string or symbol like ' +
            '"my_handler" to be used for namespacing the handler\'s storage.'
        )
      end

      key.split(/::/).last.downcase
    end
  end
end
