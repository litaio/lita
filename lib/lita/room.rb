# frozen_string_literal: true

require "redis-namespace"

require_relative "util"

module Lita
  # A room in the chat service. Persisted in Redis.
  # @since 4.4.0
  class Room
    class << self
      # Creates a new room with the given ID, or merges and saves supplied
      # metadata to a room with the given ID.
      # @param id [Integer, String] A unique identifier for the room.
      # @param metadata [Hash] An optional hash of metadata about the room.
      # @option metadata [String] name (id) The display name of the room.
      # @return [Room] The room.
      def create_or_update(id, metadata = {})
        existing_room = find_by_id(id)
        metadata = Util.stringify_keys(metadata)
        metadata = existing_room.metadata.merge(metadata) if existing_room
        room = new(id, metadata)
        room.save
        room
      end

      # Finds a room by ID.
      # @param id [Integer, String] The room's unique ID.
      # @return [Room, nil] The room or +nil+ if no such room is known.
      def find_by_id(id)
        metadata = redis.hgetall("id:#{id}")
        new(id, metadata) if metadata.key?("name")
      end

      # Finds a room by display name.
      # @param name [String] The room's name.
      # @return [Room, nil] The room or +nil+ if no such room is known.
      def find_by_name(name)
        id = redis.get("name:#{name}")
        find_by_id(id) if id
      end

      # Finds a room by ID or name
      # @param identifier [Integer, String] The room's ID or name.
      # @return [Room, nil] The room or +nil+ if no room was found.
      def fuzzy_find(identifier)
        find_by_id(identifier) || find_by_name(identifier)
      end

      # The +Redis::Namespace+ for room persistence.
      # @return [Redis::Namespace] The Redis connection.
      def redis
        @redis ||= Redis::Namespace.new("rooms", redis: Lita.redis)
      end
    end

    # The room's unique ID.
    # @return [String] The room's ID.
    attr_reader :id

    # A hash of arbitrary metadata about the room.
    # @return [Hash] The room's metadata.
    attr_reader :metadata

    # The room's name as displayed in a standard user interface.
    # @return [String] The room's name.
    attr_reader :name

    # @param id [Integer, String] The room's unique ID.
    # @param metadata [Hash] Arbitrary room metadata.
    # @option metadata [String] name (id) The room's display name.
    def initialize(id, metadata = {})
      @id = id.to_s
      @metadata = Util.stringify_keys(metadata)
      @name = @metadata["name"] || @id
    end

    # Compares the room against another room object to determine equality. Rooms
    # are considered equal if they have the same ID.
    # @param other [Room] The room to compare against.
    # @return [Boolean] True if rooms are equal, false otherwise.
    def ==(other)
      other.respond_to?(:id) && id == other.id
    end
    alias eql? ==

    # Generates a +Fixnum+ hash value for this user object. Implemented to support equality.
    # @return [Fixnum] The hash value.
    # @see Object#hash
    def hash
      id.hash
    end

    # Saves the room record to Redis, overwriting any previous data for the current ID.
    # @return [void]
    def save
      ensure_name_metadata_set

      redis.pipelined do |pipeline|
        pipeline.hmset("id:#{id}", *metadata.to_a.flatten)
        pipeline.set("name:#{name}", id)
      end
    end

    private

    # Ensure the room's metadata contains its name, to ensure their Redis hash contains at least
    # one value. It's not possible to store an empty hash key in Redis.
    def ensure_name_metadata_set
      room_name = metadata.delete("name")
      metadata["name"] = room_name || id
    end

    # The Redis connection for room persistence.
    def redis
      self.class.redis
    end
  end
end
