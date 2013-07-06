module Lita
  # A wrapper object representing the source of an incoming message (the user
  # who sent it, and optionally the room they sent it from). If a room is set,
  # the message is from a group chat room. If no room is set, the message is
  # assumed to be a private message. Source objects are also used as "target"
  # objects when sending an outgoing message or performing another operation
  # on a user or a room.
  class Source

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
    def initialize(user, room = nil)
      @user = user
      @room = room
    end
  end
end
