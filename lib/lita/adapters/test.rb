# frozen_string_literal: true

require_relative "../adapter"

module Lita
  # A namespace to hold all subclasses of {Adapter}.
  module Adapters
    # An adapter for testing Lita and Lita plugins.
    # @since 4.6.0
    class Test < Adapter
      # When true, calls to {#run_concurrently} will block the current thread. This is the default
      # because it's desirable for the majority of tests. It should be set to +false+ for tests
      # specifically testing asynchrony.
      config :blocking, types: [TrueClass, FalseClass], default: true

      # Adapter-specific methods exposed through {Robot}.
      class ChatService
        def initialize(sent_messages)
          @sent_messages = sent_messages
        end

        # An array of recorded outgoing messages.
        def sent_messages
          @sent_messages.dup
        end
      end

      def initialize(robot)
        super

        self.sent_messages = []
      end

      # Adapter-specific methods available via {Robot#chat_service}.
      def chat_service
        ChatService.new(sent_messages)
      end

      # Records outgoing messages.
      def send_messages(_target, strings)
        sent_messages.concat(strings)
      end

      # If the +blocking+ config attribute is +true+ (which is the default), the block will be run
      # on the current thread, so tests can be written without concern for asynchrony.
      def run_concurrently(&block)
        if config.blocking
          block.call
        else
          super
        end
      end

      private

      # An array of recorded outgoing messages.
      attr_accessor :sent_messages
    end

    Lita.register_adapter(:test, Test)
  end
end
