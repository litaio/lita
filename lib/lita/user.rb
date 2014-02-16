module Lita
  # A user in the chat service. Persisted in Redis.
  class User
    class << self
      # The +Redis::Namespace+ for user persistence.
      # @return [Redis::Namespace] The Redis connection.
      def redis
        @redis ||= Redis::Namespace.new("users", redis: Lita.redis)
      end

      # Finds or creates a user. Attempts to find a user with the given ID. If
      # none is found, creates a user with the provided ID and metadata.
      # @param id [Integer, String] A unique identifier for the user.
      # @param metadata [Hash] An optional hash of metadata about the user.
      # @option metadata [String] name (id) The display name of the user.
      # @return [Lita::User] The user.
      def create(id, metadata = {})
        user = find_by_id(id)
        unless user
          user = new(id, metadata)
          user.save
        end
        user
      end
      alias_method :find, :create

      # Finds a user by ID.
      # @param id [Integer, String] The user's unique ID.
      # @return [Lita::User, nil] The user or +nil+ if no such user is known.
      def find_by_id(id)
        metadata = redis.hgetall("id:#{id}")
        new(id, metadata) if metadata.key?("name")
      end

      # Finds a user by display name.
      # @param name [String] The user's name.
      # @return [Lita::User, nil] The user or +nil+ if no such user is known.
      def find_by_name(name)
        id = redis.get("name:#{name}")
        find_by_id(id) if id
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
      @metadata = metadata
      @name = @metadata[:name] || @metadata["name"] || @id
    end

    # Saves the user record to Redis, overwriting an previous data for the
    # current ID and user name.
    # @return [void]
    def save
      redis.pipelined do
        redis.hmset("id:#{id}", *metadata.to_a.flatten)
        redis.set("name:#{name}", id)
      end
    end

    # Compares the user against another user object to determine equality. Users
    # are considered equal if they have the same ID and name.
    # @param other (Lita::User) The user to compare against.
    # @return [Boolean] True if users are equal, false otherwise.
    def ==(other)
      other.respond_to?(:id) && id == other.id && other.respond_to?(:name) && name == other.name
    end

    private

    # The Redis connection for user persistence.
    def redis
      self.class.redis
    end
  end
end
