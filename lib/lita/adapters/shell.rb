module Lita
  module Adapters
    # An adapter that runs Lita in a UNIX shell.
    class Shell < Adapter
      # Creates a "Shell User" and then loops a prompt and input, passing the
      # incoming messages to the robot.
      # @return [void]
      def run
        user = User.create(1, name: "Shell User")
        @source = Source.new(user: user)
        puts 'Type "exit" or "quit" to end the session.'
        robot.trigger(:connected)

        run_loop
      end

      # Outputs outgoing messages to the shell.
      # @param target [Lita::Source] Unused, since there is only one user in the
      #   shell environment.
      # @param strings [Array<String>] An array of strings to output.
      # @return [void]
      def send_messages(target, strings)
        strings = Array(strings)
        strings.reject! { |string| string.empty? }
        unless RbConfig::CONFIG["host_os"] =~ /mswin|mingw/ || !$stdout.tty?
          strings.map! { |string| "\e[32m#{string}\e[0m" }
        end
        puts strings
      end

      # Adds a blank line for a nice looking exit.
      # @return [void]
      def shut_down
        puts
      end

      private

      def build_message(input, source)
        message = Message.new(robot, input, source)
        message.command! if Lita.config.adapter.private_chat
        message
      end

      def run_loop
        loop do
          print "#{robot.name} > "
          input = $stdin.gets
          input.nil? && puts && break
          input = input.chomp.strip
          break if input == "exit" || input == "quit"
          robot.receive(build_message(input, @source))
        end
      end
    end

    Lita.register_adapter(:shell, Shell)
  end
end
