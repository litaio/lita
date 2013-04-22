require "forwardable"

require "lita/adapter"

module Lita
  class Robot
    extend Forwardable

    attr_reader :adapter, :name

    def_delegators :adapter, :run, :say, :reply

    def initialize(config)
      @adapter = Adapter.load_adapter(config.adapter.name).new(config)
      @name = config.robot.name
    end
  end
end
