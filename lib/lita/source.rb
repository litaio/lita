# frozen_string_literal: true

require "i18n"

require_relative "room"

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
    alias private_message? private_message

    # The room the message came from or should be sent to, as a string.
    # @return [String, NilClass] A string uniquely identifying the room.
    attr_reader :room

    # The room the message came from or should be sent to, as a {Room} object.
    # @return [Room, NilClass] The room.
    # @since 4.4.0
    attr_reader :room_object

    # The user who sent the message or should receive the outgoing message.
    # @return [User, NilClass] The user.
    attr_reader :user

    # @param user [User] The user who sent the message or should receive
    #   the outgoing message.
    # @param room [Room, String] A string or {Room} uniquely identifying the room
    #   the user sent the message from, or the room where a reply should go. The format of this
    #   string (or the ID of the {Room} object) will differ depending on the chat service.
    # @param private_message [Boolean] A flag indicating whether or not the
    #   message was sent privately.
    def initialize(user: nil, room: nil, private_message: false)
      @user = user

      case room
      when String
        @room = room
        @room_object = load_with_metadata(room)
      when Room
        @room = room.id
        @room_object = room
      end

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

    private

    def load_with_metadata(room_id)
      Room.find_by_id(room_id) || Room.new(room_id)
    end
  end

  # An alias for {Source}. Since source objects are used for both incoming and outgoing messages, it
  # might be helpful to think of an outgoing messsage's source as a "target" rather than a source.
  #
  # @see Source
  # @since 5.0.0
  Target = Source
end
