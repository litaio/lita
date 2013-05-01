require "shellwords"

module Lita
  class Message
    attr_reader :body, :user

    def initialize(body, user)
      @body = body
      @user = user
    end

    def parse_command(robot_name)
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
