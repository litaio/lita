module Lita
  module Listener
    class Echo < Base
      def call
        input = message =~ /^echo\s+(.+)/ && $1
        say(input) if input
      end
    end
  end
end
