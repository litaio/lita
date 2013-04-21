require "lita/adapter/shell"
require "lita/storage"

module Lita
  class Robot
    extend Forwardable

    def_delegators :@adapter, :run, :say
    def_delegators :@storage, :get, :set

    def initialize(config)
      @adapter = Adapter.load_adapter(config.robot.adapter).new(self)
      @storage = Storage.new
      @name = config.robot.name
    end

    def receive(message)
      directed = message.gsub!(/^#{@name}\s*/i, "")
      listeners.each { |listener| listener.new(self, message, !!directed).call }
    end

    private

    def listeners
      Lita.listeners
    end
  end
end
