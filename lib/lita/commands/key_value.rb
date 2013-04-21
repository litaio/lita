module Lita
  module Commands
    class Set < Command
      command "set"

      description "Sets the value of a key."

      storage_key :key_value

      def call
        set(message.args[0], message.args[1])
      end
    end

    class Get < Command
      command "get"

      description "Says the value of a key."

      storage_key :key_value

      def call
        say get(message.args[0])
      end
    end
  end
end
