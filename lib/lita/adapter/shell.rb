require "lita/adapter"

module Lita
  module Adapter
    class Shell < Base
      def run
        puts 'Type "exit" to end the session.'
        loop do
          print "> "
          message = gets.chomp
          break if message == "exit"
          robot.receive(message)
        end
      end

      def say(message)
        puts message
      end
    end
  end
end
