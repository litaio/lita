module Lita
  module Adapters
    class Shell < Adapter
      def run
        loop do
          print "#{robot.name} > "
          input = gets.chomp.strip
          break if input == "exit" || input == "quit"
          robot.receive(input)
        end
      end

      def say(message, *strings)
        puts *strings
      end
    end

    Lita.register_adapter(:shell, Shell)
  end
end
