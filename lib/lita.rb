require "forwardable"
require "logger"
require "set"
require "shellwords"

require "multi_json"
require "rack"
require "redis-namespace"
require "thin"

require "lita/version"
require "lita/config"

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

    def clear_config
      @config = nil
    end

    def logger
      @logger ||= Logger.get_logger(Lita.config.robot.log_level)
    end

    def redis
      @redis ||= begin
        redis = Redis.new(config.redis)
        Redis::Namespace.new(REDIS_NAMESPACE, redis: redis)
      end
    end

    def run(config_path = nil)
      Config.load_user_config(config_path)
      Robot.new.run
    end
  end
end

require "lita/util"
require "lita/logger"
require "lita/user"
require "lita/source"
require "lita/authorization"
require "lita/message"
require "lita/response"
require "lita/http_route"
require "lita/rack_app_builder"
require "lita/robot"
require "lita/adapter"
require "lita/adapters/shell"
require "lita/handler"
require "lita/handlers/authorization"
require "lita/handlers/help"
require "lita/handlers/web"
