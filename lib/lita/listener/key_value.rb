module Lita
  module Listener
    class KeyValue < Base
      def call(message)
        command, *args = message.split(/\s+/)

        case command
        when "set"
          set(args[0], args[1])
        when "get"
          say get(args[0])
        end
      end
    end
  end
end
