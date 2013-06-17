module Lita
  class User
    class << self
      def redis
        @redis ||= Redis::Namespace.new("users", redis: Lita.redis)
      end

      def find(id)
        name = redis.get("id:#{id}")
        return new(id, name) if name
      end

      def find_by_name(name)
        id = redis.get("name:#{name}")
        return new(id, name) if id
      end

      def create(id, name)
        user = find(id)
        unless user
          user = new(id, name)
          user.save
        end
        user
      end
    end

    attr_reader :id, :name

    def initialize(id, name)
      @id = id.to_s
      @name = name
    end

    def save
      redis.pipelined do
        redis.set("id:#{id}", name)
        redis.set("name:#{name}", id)
      end
    end

    def ==(other)
      id == other.id && name == other.name
    end

    private

    def redis
      self.class.redis
    end
  end
end
