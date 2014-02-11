module Lita
  # A wrapper object representing the source of an incoming message (either the
  # user who sent it, the room they sent it from, or both). If a room is set,
  # the message is from a group chat room. If no room is set, the message is
  # assumed to be a private message, though Source objects can be explicitly
  # marked as private messages. Source objects are also used as "target" objects
  # when sending an outgoing message or performing another operation on a user
  # or a room.
  class Source
    # A flag indicating that a message was sent to the robot privately.
    # @return [Boolean] The boolean flag.
    attr_reader :private_message
    alias_method :private_message?, :private_message

    # The room the message came from or should be sent to.
    # @return [String] A string uniquely identifying the room.
    attr_reader :room

    # The user who sent the message or should receive the outgoing message.
    # @return [Lita::User] The user.
    attr_reader :user

    # @param user [Lita::User] The user who sent the message or should receive
    #   the outgoing message.
    # @param room [String] A string uniquely identifying the room the user sent
    #   the message from, or the room where a reply should go. The format of
    #   this string will differ depending on the chat service.
    # @param private_message [Boolean] A flag indicating whether or not the
    #   message was sent privately.
    def initialize(user: nil, room: nil, private_message: false)
      @user = user
      @room = room
      @private_message = private_message

      raise ArgumentError, I18n.t("lita.source.user_or_room_required") if user.nil? && room.nil?

      @private_message = true if room.nil?
    end

    # Destructively marks the source as a private message, meaning an incoming
    # message was sent to the robot privately, or an outgoing message should be
    # sent to a user privately.
    # @return [void]
    def private_message!
      @private_message = true
    end
  end
end
