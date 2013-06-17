module Lita
  module Adapters
    class Shell < Adapter
      def run
        user = User.new(1, "Shell User")
        source = Source.new(user)
        puts 'Type "exit" or "quit" to end the session.'

        loop do
          print "#{robot.name} > "
          input = gets.chomp.strip
          break if input == "exit" || input == "quit"
          message = Message.new(robot, input, source)
          robot.receive(message)
        end
      end

      def send_messages(target, *strings)
        puts *strings
      end
    end

    Lita.register_adapter(:shell, Shell)
  end
end
