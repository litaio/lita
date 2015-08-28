module Lita
  # A namespace to hold all subclasses of {Adapter}.
  module Adapters
    # An adapter for testing Lita and Lita plugins.
    # @since 4.6.0
    class Test < Adapter
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

      private

      # An array of recorded outgoing messages.
      attr_accessor :sent_messages
    end

    Lita.register_adapter(:test, Test)
  end
end
