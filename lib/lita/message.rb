module Lita
  # Represents an incoming chat message.
  class Message
    extend Forwardable

    # The body of the message.
    # @return [String] The message body.
    attr_reader :body

    # The source of the message, which is a user and optional room.
    # @return [Lita::Source] The message source.
    attr_reader :source

    # @!method user
    # The user who sent the message.
    # @return [Lita::User] The user.
    # @see Lita::Source#user
    def_delegators :source, :user

    # @param robot [Lita::Robot] The currently running robot.
    # @param body [String] The body of the message.
    # @param source [Lita::Source] The source of the message.
    def initialize(robot, body, source)
      @robot = robot
      @body = body
      @source = source

      name_pattern = Regexp.escape(@robot.mention_name)
      name_pattern = "#{name_pattern}|#{Regexp.escape(@robot.alias)}" if @robot.alias

      @command = !!@body.sub!(/^\s*@?(?:#{name_pattern})[:,]?\s*/i, "")
    end

    # An array of arguments created by shellsplitting the message body, as if
    # it were a shell command.
    # @return [Array<String>] The array of arguments.
    def args
      begin
        _command, *args = body.shellsplit
      rescue ArgumentError
        _command, *args =
          body.split(/\s+/).map(&:shellescape).join(" ").shellsplit
      end

      args
    end

    # Marks the message as a command, meaning it was directed at the robot
    # specifically.
    # @return [void]
    def command!
      @command = true
    end

    # A boolean representing whether or not the message was a command.
    # @return [Boolean] +true+ if the message was a command, +false+ if not.
    def command?
      @command
    end

    # An array of matches against the message body for the given {::Regexp}.
    # @param pattern [Regexp] A pattern to match.
    # @return [Array<String>, Array<Array<String>>] An array of matches.
    def match(pattern)
      body.scan(pattern)
    end

    # Replies by sending the given strings back to the source of the message.
    # @param strings [String, Array<String>] The strings to send back.
    # @return [void]
    def reply(*strings)
      @robot.send_messages(source, *strings)
    end

    # Replies by sending the given strings back to the user who sent the
    # message directly, even if the message was sent in a room.
    # @param strings [String, Array<String>] The strings to send back.
    # @return [void]
    def reply_privately(*strings)
      private_source = source.clone
      private_source.private_message!
      @robot.send_messages(private_source, *strings)
    end

    # Replies by sending the given strings back to the source of the message.
    # Each message is prefixed with the user's mention name.
    # @param strings [String, Array<String>] The strings to send back.
    # @return [void]
    # @since 3.1.0
    def reply_with_mention(*strings)
      @robot.send_messages_with_mention(source, *strings)
    end
  end
end
