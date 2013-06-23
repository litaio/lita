module Lita
  class Message
    extend Forwardable

    attr_reader :body, :source
    alias_method :message, :body

    def_delegators :@body, :scan
    def_delegators :@source, :user

    def initialize(robot, body, source)
      @robot = robot
      @body = body
      @source = source

      @command = !!@body.sub!(/^\s*@?#{@robot.mention_name}[:,]?\s*/, "")
    end

    def args
      begin
        command, *args = message.shellsplit
      rescue ArgumentError
        command, *args =
          message.split(/\s+/).map(&:shellescape).join(" ").shellsplit
      end

      args
    end

    def command!
      @command = true
    end

    def command?
      @command
    end
  end
end
