module Lita
  # A namespace to hold all subclasses of {Adapter}.
  module Adapters
    # An adapter that runs Lita in a UNIX shell.
    class Shell < Adapter
      config :private_chat, default: false

      # Creates a "Shell User" and then loops a prompt and input, passing the
      # incoming messages to the robot.
      # @return [void]
      def run
        user = User.create(1, name: "Shell User")
        @source = Source.new(user: user)
        puts t("startup_message")
        robot.trigger(:connected)

        run_loop
      end

      # Outputs outgoing messages to the shell.
      # @param _target [Lita::Source] Unused, since there is only one user in the
      #   shell environment.
      # @param strings [Array<String>] An array of strings to output.
      # @return [void]
      def send_messages(_target, strings)
        strings = Array(strings)
        strings.reject!(&:empty?)
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
        message.command! if robot.config.adapters.shell.private_chat
        message
      end

      def normalize_history(input)
        if input == "" || (Readline::HISTORY.size >= 2 && input == Readline::HISTORY[-2])
          Readline::HISTORY.pop
        end
      end

      def normalize_input(input)
        input.chomp.strip
      end

      def read_input
        input = Readline.readline("#{robot.name} > ", true)
        # Input read via rb-readline will always be encoded as US-ASCII.
        # @see https://github.com/luislavena/rb-readline/blob/master/lib/readline.rb#L1
        input.force_encoding(Encoding.default_external) if input
      end

      def run_loop
        loop do
          input = read_input
          if input.nil?
            puts
            break
          end
          input = normalize_input(input)
          normalize_history(input)
          break if input == "exit" || input == "quit"
          robot.receive(build_message(input, @source))
        end
      end
    end

    Lita.register_adapter(:shell, Shell)
  end
end
