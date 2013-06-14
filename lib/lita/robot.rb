module Lita
  class Robot
    attr_reader :name

    def initialize
      @name = Lita.config.robot.name
      load_adapter
    end

    def receive(message)
      Lita.handlers.each { |handler| handler.dispatch(self, message) }
    end

    def run
      @adapter.run
    end

    def send_message(source, target, *strings)
      @adapter.send_message(source, target, *strings)
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
