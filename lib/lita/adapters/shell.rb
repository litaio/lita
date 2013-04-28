module Lita
  module Adapters
    class Shell < Adapter
      def run
        stdout.puts('Type "exit" to end the session.')

        user = User.new(robot, "Shell User")

        loop do
          stdout.print "> "
          input = stdin.gets.chomp
          break if input == "exit"
          robot.receive(Message.new(input, user))
        end
      end

      def say(*messages)
        messages.each { |message| stdout.puts(message) }
      end
    end

    Lita.register_adapter(:shell, Shell)
  end
end
