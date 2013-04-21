require "shellwords"

module Lita
  class Message
    attr_reader :body, :user

    def initialize(body, user)
      @body = body
      @user = user
    end

    def full_args
      begin
        body.shellsplit
      rescue ArgumentError
        body.shellescape.shellsplit
      end
    end

    def args
      args = full_args
      args.shift
      args
    end

    def command
      full_args.first
    end

    def command?
      true
    end

    def ==(other)
      body == other
    end

    def to_s
      body
    end
  end
end
