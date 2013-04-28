require "forwardable"

require "lita/adapter"
require "lita/storage"
require "lita/handler"

module Lita
  class Robot
    extend Forwardable

    attr_reader :adapter, :storage, :name

    def_delegators :adapter, :run, :say, :reply

    def initialize(config)
      adapter_class = Adapter.load_adapter(config.adapter.name)
      @adapter = adapter_class.new(self, config.adapter)
      @storage = Storage.new(config.redis_options)
      @name = config.robot.name
    end

    def receive(message)
    end
  end
end
