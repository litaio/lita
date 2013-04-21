require "lita/base_listener"

module Lita
  class Listener < BaseListener
    class << self
      def inherited(klass)
        Lita.listeners << klass
      end

      def listen(matcher)
        @matcher = matcher
      end

      def applies?(message)
        @matcher === message.body
      end
    end
  end
end

require "lita/listeners/greet"
