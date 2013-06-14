module Lita
  module Adapters
    class Shell < Adapter
      def run
        loop do
          print "#{robot.name} > "
          input = gets.chomp.strip
          break if input == "exit" || input == "quit"
          source = Source.new("Shell User")
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
