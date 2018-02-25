# frozen_string_literal: true

require "redis-namespace"

require_relative "util"

module Lita
  # A user in the chat service. Persisted in Redis.
  class User
    class << self
      # The +Redis::Namespace+ for user persistence.
      # @return [Redis::Namespace] The Redis connection.
      def redis
        @redis ||= Redis::Namespace.new("users", redis: Lita.redis)
      end

      # Creates a new user with the given ID, or merges and saves supplied
      # metadata to an existing user with the given ID.
      # @param id [Integer, String] A unique identifier for the user.
      # @param metadata [Hash] An optional hash of metadata about the user.
      # @option metadata [String] name (id) The display name of the user.
      # @return [User] The user.
      def create(id, metadata = {})
        existing_user = find_by_id(id)
        metadata = Util.stringify_keys(metadata)
        metadata = existing_user.metadata.merge(metadata) if existing_user
        user = new(id, metadata)
        user.save
        user
      end

      # Finds a user by ID.
      # @param id [Integer, String] The user's unique ID.
      # @return [User, nil] The user or +nil+ if no such user is known.
      def find_by_id(id)
        metadata = redis.hgetall("id:#{id}")
        new(id, metadata) if metadata.key?("name")
      end

      # Finds a user by mention name.
      # @param mention_name [String] The user's mention name.
      # @return [User, nil] The user or +nil+ if no such user is known.
      # @since 3.0.0
      def find_by_mention_name(mention_name)
        id = redis.get("mention_name:#{mention_name}")
        find_by_id(id) if id
      end

      # Finds a user by display name.
      # @param name [String] The user's name.
      # @return [User, nil] The user or +nil+ if no such user is known.
      def find_by_name(name)
        id = redis.get("name:#{name}")
        find_by_id(id) if id
      end

      # Attempts to find a user with a name starting with the provided string.
      # @param name [String] The first characters in the user's name.
      # @return [User, nil] The user, or +nil+ if zero or greater than 1 matches were found.
      # @since 3.0.0
      def find_by_partial_name(name)
        keys = redis.keys("name:#{name}*")

        if keys.length == 1
          id = redis.get(keys.first)
          find_by_id(id)
        end
      end

      # Finds a user by ID, mention name, name, or partial name.
      # @param identifier [String] The user's ID, name, partial name, or mention name.
      # @return [User, nil] The user or +nil+ if no users were found.
      # @since 3.0.0
      def fuzzy_find(identifier)
        find_by_id(identifier) || find_by_mention_name(identifier) ||
          find_by_name(identifier) || find_by_partial_name(identifier)
      end
    end

    # The user's unique ID.
    # @return [String] The user's ID.
    attr_reader :id

    # A hash of arbitrary metadata about the user.
    # @return [Hash] The user's metadata.
    attr_reader :metadata

    # The user's name as displayed in the chat.
    # @return [String] The user's name.
    attr_reader :name

    # @param id [Integer, String] The user's unique ID.
    # @param metadata [Hash] Arbitrary user metadata.
    # @option metadata [String] name (id) The user's display name.
    def initialize(id, metadata = {})
      @id = id.to_s
      @metadata = Util.stringify_keys(metadata)
      @name = @metadata["name"] || @id
      ensure_name_metadata_set
    end

    # The name used to "mention" the user in a group chat.
    # @return [String] The user's mention name.
    # @since 3.1.0
    def mention_name
      metadata["mention_name"] || name
    end

    # Saves the user record to Redis, overwriting any previous data for the
    # current ID and user name.
    # @return [void]
    def save
      mention_name = metadata[:mention_name] || metadata["mention_name"]

      current_keys = metadata.keys
      redis_keys = redis.hkeys("id:#{id}")
      delete_keys = (redis_keys - current_keys)

      redis.pipelined do
        redis.hdel("id:#{id}", *delete_keys) if delete_keys.any?
        redis.hmset("id:#{id}", *metadata.to_a.flatten)
        redis.set("name:#{name}", id)
        redis.set("mention_name:#{mention_name}", id) if mention_name
      end
    end

    # Compares the user against another user object to determine equality. Users
    # are considered equal if they have the same ID and name.
    # @param other (User) The user to compare against.
    # @return [Boolean] True if users are equal, false otherwise.
    def ==(other)
      other.respond_to?(:id) && id == other.id && other.respond_to?(:name) && name == other.name
    end
    alias eql? ==

    # Generates a +Fixnum+ hash value for this user object. Implemented to support equality.
    # @return [Fixnum] The hash value.
    # @see Object#hash
    def hash
      id.hash ^ name.hash
    end

    private

    # Ensure the user's metadata contains their name, to ensure their Redis hash contains at least
    # one value. It's not possible to store an empty hash key in Redis.
    def ensure_name_metadata_set
      username = metadata.delete("name")
      metadata["name"] = username || id
    end

    # The Redis connection for user persistence.
    def redis
      self.class.redis
    end
  end
end
