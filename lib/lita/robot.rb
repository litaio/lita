require "lita/adapters/shell"
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
      call_applicable(Lita.commands, message) if message.command?
      call_applicable(Lita.listeners, message)
    end

    private

    def call_applicable(listener_classes, message)
      listener_classes.each do |listener_class|
        if listener_class.applies?(message)
          listener_class.new(self, message).call
        end
      end
    end
  end
end
