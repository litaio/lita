module Lita
  class << self
    def run
      Robot.new.run
    end

    def listeners
      @listeners ||= []
    end
  end
end

require "lita/version"
require "lita/robot"
require "lita/listener"
