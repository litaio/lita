require "shellwords"

module Lita
  class Message
    attr_reader :body, :user

    def initialize(body, user)
      @body = body
      @user = user
    end

    def matches(pattern)
      body.scan(pattern)
    end

    def command(robot_name)
      command = command_with_args(robot_name)
      command.first if command
    end

    def args(robot_name)
      command, *args = command_with_args(robot_name)
      args if command
    end

    def command_with_args(robot_name)
      match = body.match(/^\s*@?#{robot_name}[:,]?\s*(.+)/i)
      begin
        match[1].shellsplit if match
      rescue ArgumentError
        return match[1].split(/\s+/).map(&:shellescape).join(" ").shellsplit
      end
    end

    def to_s
      body
    end
  end
end
