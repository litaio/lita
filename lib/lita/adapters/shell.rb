require "lita/adapter"
require "lita/message"
require "lita/user"

module Lita
  module Adapters
    class Shell < Adapter
      def run
        puts 'Type "exit" to end the session.'
        user = User.new(id: 1, name: "Shell")
        loop do
          print "> "
          message = Message.new(gets.chomp, user)
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
