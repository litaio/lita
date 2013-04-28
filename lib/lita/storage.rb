require "redis-namespace"

module Lita
  class Storage
    def initialize(redis_options)
      @redis = Redis.new(redis_options)
    end

    def namespaced_storage(namespace)
      Redis::Namespace.new(namespace, redis: @redis)
    end
  end
end
