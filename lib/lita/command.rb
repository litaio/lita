require "lita/base_listener"

module Lita
  class Command < BaseListener
    class << self
      def inherited(klass)
        Lita.commands << klass
      end

      def command(command)
        @command = command
      end

      def applies?(message)
        @command === message.command
      end
    end
  end
end

require "lita/commands/echo"
require "lita/commands/key_value"
