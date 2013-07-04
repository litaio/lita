module Lita
  class Robot
    attr_reader :name, :app
    attr_accessor :mention_name

    def initialize
      @name = Lita.config.robot.name
      @mention_name = Lita.config.robot.mention_name || @name
      @app = RackAppBuilder.new(self).to_app
      load_adapter
    end

    def receive(message)
      Lita.handlers.each { |handler| handler.dispatch(self, message) }
    end

    def run
      run_app
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
      @server.stop if @server
      @server_thread.join if @server_thread
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

    def run_app
      @server_thread = Thread.new do
        @server = Thin::Server.new(
          app,
          Lita.config.http.port.to_i,
          signals: false
        )
        @server.silent = true
        @server.start
      end

      @server_thread.abort_on_exception = true
    end
  end
end
