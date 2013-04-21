module Lita
  module Listeners
    class Greet < Listener
      listen "hello"

      description "Responds to greetings in kind."

      def call
        say "Hello, there!"
      end
    end
  end
end
