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
    rescue Interrupt
      shut_down
    end

    def send_messages(target, *strings)
      @adapter.send_messages(target, strings.flatten)
    end
    alias_method :send_message, :send_messages

    def set_topic(target, topic)
      @adapter.set_topic(target, topic)
    end

    def shut_down
      @adapter.shut_down
    end

    private

    def load_adapter
      adapter_name = Lita.config.robot.adapter
      adapter_class = Lita.adapters[adapter_name.to_sym]

      unless adapter_class
        Lita.logger.fatal("Unknown adapter: :#{adapter_name}.")
        abort
      end

      @adapter = adapter_class.new(self)
    end
  end
end
