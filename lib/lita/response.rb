module Lita
  # A wrapper object that provides the primary interface for handlers to
  # respond to incoming chat messages.
  class Response
    extend Forwardable

    # The incoming message.
    # @return [Lita::Message] The message.
    attr_accessor :message

    # The pattern the incoming message matched.
    # @return [Regexp] The pattern.
    attr_accessor :pattern

    # @!method args
    #   @see Lita::Message#args
    # @!method reply
    #   @see Lita::Message#reply
    # @!method reply
    #   @see Lita::Message#reply_to_user
    # @!method reply_privately
    #   @see Lita::Message#reply_privately
    # @!method user
    #   @see Lita::Message#user
    def_delegators :message, :args, :reply, :reply_to_user, :reply_privately, :user, :command?

    # @param message [Lita::Message] The incoming message.
    # @param pattern [Regexp] The pattern the incoming message matched.
    def initialize(message, pattern)
      self.message = message
      self.pattern = pattern
    end

    # An array of matches from scanning the message against the route pattern.
    # @return [Array<String>, Array<Array<String>>] The array of matches.
    def matches
      @matches ||= message.match(pattern)
    end

    # A +MatchData+ object from running the pattern against the message body.
    # @return [MatchData] The +MatchData+.
    def match_data
      @match_data ||= pattern.match(message.body)
    end
  end
end
