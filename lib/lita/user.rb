module Lita
  class User
    attr_reader :id

    def initialize(robot, id)
      @robot = robot
      @id = id
    end
  end
end
