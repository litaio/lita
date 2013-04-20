module Lita
  module Listener
    class Echo < Base
      def self.call(robot, message)
        input = message =~ /^echo\s+(.+)/ && $1
        robot.say(input) if input
      end
    end
  end
end
