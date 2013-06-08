module Lita
  class Adapter
    attr_reader :robot

    def initialize(robot)
      @robot = robot
    end
  end
end
