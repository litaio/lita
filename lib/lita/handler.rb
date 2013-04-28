require "forwardable"

module Lita
  class Handler
    class << self
      attr_accessor :listeners

      def listener(method, pattern)
        @listeners ||= []
        @listeners << { method: method, pattern: pattern }
      end

      def dispatch(robot, message)
        listeners.each do |listener|
          matches = message.scan(listener[:pattern])

          unless matches.empty?
            new(robot, message, matches).public_send(listener[:method])
          end
        end
      end
    end

    extend Forwardable

    attr_reader :robot, :message, :matches

    def_delegators :robot, :say

    def initialize(robot, message, matches)
      @robot = robot
      @message = message
      @matches = matches
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
