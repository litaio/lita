require "forwardable"
require "logger"
require "set"
require "shellwords"

require "redis-namespace"

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

    def logger
      @logger ||= begin
        logger = Logger.new(STDERR)
        logger.level = log_level
        logger.formatter = proc do |severity, datetime, progname, msg|
          "[#{datetime.utc}] #{severity}: #{msg}\n"
        end
        logger
      end
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

    private

    def log_level
      level = config.robot.log_level

      if level
        begin
          Logger.const_get(level.to_s.upcase)
        rescue NameError
          return Logger::INFO
        end
      else
        Logger::INFO
      end
    end
  end
end

require "lita/user"
require "lita/source"
require "lita/authorization"
require "lita/message"
require "lita/response"
require "lita/robot"
require "lita/adapter"
require "lita/adapters/shell"
require "lita/handler"
require "lita/handlers/authorization"
require "lita/handlers/help"
