module Lita
  # The main object representing a running instance of Lita. Provides a high
  # level API for the underlying adapter. Dispatches incoming messages to
  # registered handlers. Can send outgoing chat messages and set the topic
  # of chat rooms.
  class Robot
    # A +Rack+ application used for the built-in web server.
    # @return [Rack::Builder] The +Rack+ app.
    attr_reader :app

    # The name the robot will look for in incoming messages to determine if it's
    # being addressed.
    # @return [String] The mention name.
    attr_accessor :mention_name

    # An alias the robot will look for in incoming messages to determine if it's
    # being addressed.
    # @return [String, Nil] The alias, if one was set.
    attr_accessor :alias

    # The name of the robot as it will appear in the chat.
    # @return [String] The robot's name.
    attr_reader :name

    def initialize
      @name = Lita.config.robot.name
      @mention_name = Lita.config.robot.mention_name || @name
      @alias = Lita.config.robot.alias
      @app = RackApp.new(self)
      load_adapter
      trigger(:loaded)
    end

    # The primary entry point from the adapter for an incoming message.
    # Dispatches the message to all registered handlers.
    # @param message [Lita::Message] The incoming message.
    # @return [void]
    def receive(message)
      Lita.handlers.each { |handler| handler.dispatch(self, message) }
    end

    # Starts the robot, booting the web server and delegating to the adapter to
    # connect to the chat service.
    # @return [void]
    def run
      run_app
      @adapter.run
    rescue Interrupt
      shut_down
    end

    # Makes the robot join a room with the specified ID.
    # @param room_id [String] The ID of the room.
    # @return [void]
    # @since 3.0.0
    def join(room_id)
      @adapter.join(room_id)
    end

    # Makes the robot part from the room with the specified ID.
    # @param room_id [String] The ID of the room.
    # @return [void]
    # @since 3.0.0
    def part(room_id)
      @adapter.part(room_id)
    end

    # Sends one or more messages to a user or room.
    # @param target [Lita::Source] The user or room to send to. If the Source
    #   has a room, it will choose the room. Otherwise, it will send to the
    #   user.
    # @param strings [String, Array<String>] One or more strings to send.
    # @return [void]
    def send_messages(target, *strings)
      @adapter.send_messages(target, strings.flatten)
    end
    alias_method :send_message, :send_messages

    def send_messages_with_mention(target, *strings)
    end

    # Sets the topic for a chat room.
    # @param target [Lita::Source] A source object specifying the room.
    # @param topic [String] The new topic message to set.
    # @return [void]
    def set_topic(target, topic)
      @adapter.set_topic(target, topic)
    end

    # Gracefully shuts the robot down, stopping the web server and delegating
    # to the adapter to perform any shut down tasks necessary for the chat
    # service.
    # @return [void]
    def shut_down
      trigger(:shut_down_started)
      @server.stop(true) if @server
      @server_thread.join if @server_thread
      @adapter.shut_down
      trigger(:shut_down_complete)
    end

    # Triggers an event, instructing all registered handlers to invoke any
    # methods subscribed to the event, and passing them a payload hash of
    # arbitrary data.
    # @param event_name [String, Symbol] The name of the event to trigger.
    # @param payload [Hash] An optional hash of arbitrary data.
    # @return [void]
    def trigger(event_name, payload = {})
      Lita.handlers.each do |handler|
        handler.trigger(self, event_name, payload)
      end
    end

    private

    # Loads the selected adapter.
    def load_adapter
      adapter_name = Lita.config.robot.adapter
      adapter_class = Lita.adapters[adapter_name.to_sym]

      unless adapter_class
        Lita.logger.fatal I18n.t("lita.robot.unknown_adapter", adapter: adapter_name)
        abort
      end

      @adapter = adapter_class.new(self)
    end

    # Starts the web server.
    def run_app
      http_config = Lita.config.http

      @server_thread = Thread.new do
        @server = Puma::Server.new(app)
        @server.add_tcp_listener(http_config.host, http_config.port.to_i)
        @server.min_threads = http_config.min_threads
        @server.max_threads = http_config.max_threads
        @server.run
      end

      @server_thread.abort_on_exception = true
    end
  end
end
