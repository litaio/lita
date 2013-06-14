module Lita
  class Source
    attr_reader :user, :room

    def initialize(user, room = nil)
      @user = user
      @room = room
    end
  end
end
