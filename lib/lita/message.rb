module Lita
  class Message
    extend Forwardable

    attr_reader :body, :source

    def_delegators :body, :scan
    def_delegators :source, :user

    def initialize(robot, body, source)
      @robot = robot
      @body = body
      @source = source

      @command = !!@body.sub!(/^\s*@?#{@robot.mention_name}[:,]?\s*/i, "")
    end

    def args
      begin
        command, *args = body.shellsplit
      rescue ArgumentError
        command, *args =
          body.split(/\s+/).map(&:shellescape).join(" ").shellsplit
      end

      args
    end

    def command!
      @command = true
    end

    def command?
      @command
    end

    def match(pattern)
      body.scan(pattern)
    end

    def reply(*strings)
      @robot.send_messages(source, *strings)
    end
  end
end
