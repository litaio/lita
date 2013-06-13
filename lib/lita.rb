require "set"
require "shellwords"

require "redis-namespace"

module Lita
  REDIS_NAMESPACE = "lita"

  class << self
    def adapters
      @adapters ||= {}
    end

    def register_adapter(key, adapter)
      adapters[key.to_sym] = adapter
    end

    def handlers
      @handlers ||= Set.new
    end

    def register_handler(handler)
      handlers << handler
    end

    def config
      @config ||= Config.default_config
    end

    def configure
      yield config
    end

    def redis
      @redis ||= begin
        redis = Redis.new(config.redis)
        Redis::Namespace.new(REDIS_NAMESPACE, redis: redis)
      end
    end

    def run
      Config.load_user_config
      Robot.new.run
    end
  end
end

require "lita/version"
require "lita/errors"
require "lita/config"
require "lita/message"
require "lita/robot"
require "lita/adapter"
require "lita/adapters/shell"
require "lita/handler"
