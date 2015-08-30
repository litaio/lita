require "forwardable"

module Lita
  # A wrapper object that provides the primary interface for handlers to
  # respond to incoming chat messages.
  class Response
    extend Forwardable

    # The incoming message.
    # @return [Message] The message.
    attr_accessor :message

    # A hash of arbitrary data that can be populated by Lita extensions.
    # @return [Hash] The extensions data.
    # @since 3.2.0
    attr_accessor :extensions

    # The pattern the incoming message matched.
    # @return [Regexp] The pattern.
    attr_accessor :pattern

    # @!method args
    #   @see Message#args
    # @!method reply(*strings)
    #   @see Message#reply
    # @!method reply_privately(*strings)
    #   @see Message#reply_privately
    # @!method reply_with_mention(*strings)
    #   @see Message#reply_with_mention
    # @!method user
    #   @see Message#user
    # @!method private_message?
    #   @see Message#private_message?
    #   @since 4.5.0
    def_delegators :message, :args, :reply, :reply_privately,
      :reply_with_mention, :user, :private_message?, :command?

    # @!method room
    #   @see Message#room_object
    #   @since 4.5.0
    def_delegator :message, :room_object, :room

    # @param message [Message] The incoming message.
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
