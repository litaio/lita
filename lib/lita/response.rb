module Lita
  # A wrapper object that provides the primary interface for handlers to
  # respond to incoming chat messages.
  class Response
    extend Forwardable

    # The incoming message.
    # @return [Lita::Message] The message.
    attr_accessor :message

    # A hash of arbitrary data that can be populated by Lita extensions.
    # @return [Hash] The extensions data.
    # @since 3.2.0
    attr_accessor :extensions

    # The pattern the incoming message matched.
    # @return [Regexp] The pattern.
    attr_accessor :pattern

    # @!method args
    #   @see Lita::Message#args
    # @!method reply
    #   @see Lita::Message#reply
    # @!method reply_privately
    #   @see Lita::Message#reply_privately
    # @!method reply_with_mention
    #   @see Lita::Message#reply_with_mention
    # @!method user
    #   @see Lita::Message#user
    def_delegators :message, :args, :reply, :reply_privately,
      :reply_with_mention, :user, :command?

    # @param message [Lita::Message] The incoming message.
    # @param pattern [Regexp] The pattern the incoming message matched.
    def initialize(message, pattern)
      self.message = message
      self.extensions = {}
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
