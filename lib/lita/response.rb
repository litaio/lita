module Lita
  # A wrapper object that provides the primary interface for handlers to
  # respond to incoming chat messages.
  class Response
    extend Forwardable

    # The incoming message.
    # @return [Lita::Message] The message.
    attr_accessor :message

    # An array of matches from running the message against the route pattern.
    # @return [Array<String>, Array<Array<String>>] The array of matches.
    attr_accessor :matches

    # A [MatchData] object from running the message against the route pattern.
    attr_accessor :match_data

    # @!method args
    #   @see Lita::Message#args
    # @!method reply
    #   @see Lita::Message#reply
    # @!method reply_privately
    #   @see Lita::Message#reply_privately
    # @!method user
    #   @see Lita::Message#user
    def_delegators :message, :args, :reply, :reply_privately, :user, :command?

    def_delegators :match_data, :[]

    # @param message [Lita::Message] The incoming message.
    # @param matches [Array<String>, Array<Array<String>>] The Regexp matches.
    def initialize(message, matches: nil, match_data: nil)
      self.message = message
      self.matches = matches
      self.match_data = match_data
    end
  end
end
