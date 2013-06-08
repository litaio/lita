module Lita
  class Robot
    extend Forwardable

    attr_reader :name

    def_delegators :@adapter, :run, :say

    def initialize
      @name = Lita.config.robot.name
      load_adapter
    end

    def receive(message)
      Lita.handlers.each { |handler| handler.dispatch(self, message) }
    end

    private

    def load_adapter
      adapter_name = Lita.config.adapter.name
      adapter_class = Lita.adapters[adapter_name]

      unless adapter_class
        raise UnknownAdapterError.new("Unknown adapter: :#{adapter_name}")
      end

      @adapter = adapter_class.new(self)
    end
  end
end
