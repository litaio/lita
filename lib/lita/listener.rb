require "lita/util"

module Lita
  module Listener
    class Base
      attr_reader :robot, :message, :directed

      class << self
        def inherited(klass)
          Lita.listeners << klass
        end
      end

      def initialize(robot, message, directed)
        @robot = robot
        @message = message
        @directed = directed
      end

      private

      def directed?
        !!directed
      end

      def say(message)
        robot.say(message)
      end

      def reply(message)
        robot.reply(message)
      end

      def set(key, value)
        robot.set("#{storage_prefix}:#{key}", value)
      end

      def get(key)
        robot.get("#{storage_prefix}:#{key}")
      end

      def storage_prefix
        Util.underscore(Util.demodulize(self.class.name))
      end
    end
  end
end

require "lita/listener/echo"
require "lita/listener/key_value"
