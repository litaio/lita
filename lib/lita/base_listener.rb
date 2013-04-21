require "lita/util"

module Lita
  class BaseListener
    class << self
      def description(description)
        @description = description
      end

      def storage_key(key = nil)
        if key.nil?
          @storage_key
        else
          @storage_key = key
        end
      end
    end

    attr_reader :robot, :message

    def initialize(robot, message)
      @robot = robot
      @message = message
    end

    private

    def say(message)
      robot.say(message)
    end

    def reply(message)
      robot.reply(message)
    end

    def set(key, value)
      robot.set("#{storage_key}:#{key}", value)
    end

    def get(key)
      robot.get("#{storage_key}:#{key}")
    end

    def storage_key
      self.class.storage_key ||
        Util.underscore(Util.demodulize(self.class.name))
    end
  end
end
