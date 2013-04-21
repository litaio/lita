require "lita/util"

module Lita
  module Listener
    class Base
      class << self
        def inherited(klass)
          Lita.listeners << klass
        end
      end

      def initialize(robot)
        @robot = robot
      end

      private

      def say(message)
        @robot.say(message)
      end

      def set(key, value)
        @robot.set("#{storage_prefix}:#{key}", value)
      end

      def get(key)
        @robot.get("#{storage_prefix}:#{key}")
      end

      def storage_prefix
        Util.underscore(Util.demodulize(self.class.name))
      end
    end
  end
end

require "lita/listener/echo"
require "lita/listener/key_value"
