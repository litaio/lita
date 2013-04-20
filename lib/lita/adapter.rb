module Lita
  module Adapter
    class Base
      attr_reader :robot

      def initialize(robot)
        @robot = robot
      end
    end
  end
end
