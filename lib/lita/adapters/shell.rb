module Lita
  module Adapters
    class Shell < Adapter
      def run
        user = User.create(1, name: "Shell User")
        source = Source.new(user)
        puts 'Type "exit" or "quit" to end the session.'

        loop do
          print "#{robot.name} > "
          input = $stdin.gets.chomp.strip
          break if input == "exit" || input == "quit"
          message = Message.new(robot, input, source)
          message.command! if Lita.config.adapter.private_chat
          robot.receive(message)
        end
      end

      def send_messages(target, strings)
        puts strings
      end

      def shut_down
        puts
      end
    end

    Lita.register_adapter(:shell, Shell)
  end
end
