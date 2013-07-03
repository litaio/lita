module Lita
  class Response
    extend Forwardable

    attr_accessor :message, :matches

    def_delegators :message, :args, :reply, :user

    def initialize(message, matches: nil)
      self.message = message
      self.matches = matches
    end
  end
end
