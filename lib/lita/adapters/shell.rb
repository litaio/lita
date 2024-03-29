# frozen_string_literal: true

require "rbconfig"

require "readline"

require_relative "../adapter"
require_relative "../message"
require_relative "../source"
require_relative "../user"

module Lita
  # A namespace to hold all subclasses of {Adapter}.
  module Adapters
    # An adapter that runs Lita in a UNIX shell.
    class Shell < Adapter
      config :private_chat, default: false

      def initialize(robot)
        super

        self.user = User.create(1, name: "Shell User")
      end

      # rubocop:disable Lint/UnusedMethodArgument

      # Returns the users in the room, which is only ever the "Shell User."
      # @param room [Room] The room to return a roster for. Not used in this adapter.
      # @return [Array<User>] The users in the room.
      # @since 4.4.0
      def roster(room)
        [user]
      end

      # rubocop:enable Lint/UnusedMethodArgument

      # Displays a prompt and requests input in a loop, passing the incoming messages to the robot.
      # @return [void]
      def run
        room = robot.config.adapters.shell.private_chat ? nil : "shell"
        @source = Source.new(user: user, room: room)
        puts t("startup_message")
        robot.trigger(:connected)

        run_loop
      end

      # Overrides {run_concurrently} to block instead. Since there is no separate UI element for the
      # user to enter text, we need to wait for all output for the robot before printing the next
      # input prompt.
      #
      # @yield A block of code to run.
      # @return [void]
      # @since 5.0.0
      def run_concurrently(&block)
        block.call
      end

      # Outputs outgoing messages to the shell.
      # @param _target [Source] Unused, since there is only one user in the
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

      attr_accessor :user

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
        # @see https://github.com/ConnorAtherton/rb-readline/blob/9fba246073f78831b7c7129c76cc07d8476a8892/lib/readline.rb#L1
        input&.dup&.force_encoding(Encoding.default_external)
      end

      def run_loop
        exit_keywords = %w[exit quit].freeze

        loop do
          input = read_input
          if input.nil?
            puts
            break
          end
          input = normalize_input(input)
          normalize_history(input)
          break if exit_keywords.include?(input)

          robot.receive(build_message(input, @source))
        end
      end
    end

    Lita.register_adapter(:shell, Shell)
  end
end
