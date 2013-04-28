module Lita
  module Adapters
    class Shell < Adapter
      def run
        stdout.puts('Type "exit" to end the session.')

        loop do
          stdout.print "> "
          input = stdin.gets.chomp
          break if input == "exit"
          robot.receive(input)
        end
      end
    end

    Lita.register_adapter(:shell, Shell)
  end
end
