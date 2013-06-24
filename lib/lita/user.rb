module Lita
  class User
    class << self
      def redis
        @redis ||= Redis::Namespace.new("users", redis: Lita.redis)
      end

      def create(id, metadata = {})
        user = find_by_id(id)
        unless user
          user = new(id, metadata)
          user.save
        end
        user
      end
      alias_method :find, :create

      def find_by_id(id)
        metadata = redis.hgetall("id:#{id}")
        return new(id, metadata) if metadata.key?("name")
      end

      def find_by_name(name)
        id = redis.get("name:#{name}")
        find_by_id(id) if id
      end
    end

    attr_reader :id, :name, :metadata

    def initialize(id, metadata = {})
      @id = id.to_s
      @metadata = metadata
      @name = @metadata[:name] || @metadata["name"] || @id
    end

    def save
      redis.pipelined do
        redis.hmset("id:#{id}", *metadata.to_a.flatten)
        redis.set("name:#{name}", id)
      end
    end

    def ==(other)
      other.respond_to?(:id) && id == other.id &&
        other.respond_to?(:name) && name == other.name
    end

    private

    def redis
      self.class.redis
    end
  end
end
