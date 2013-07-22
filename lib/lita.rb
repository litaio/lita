require "forwardable"
require "logger"
require "set"
require "shellwords"

require "faraday"
require "multi_json"
require "rack"
require "redis-namespace"
require "thin"

require "lita/version"
require "lita/config"

# The main namespace for Lita. Provides a global registry of adapters and
# handlers, as well as global configuration, logger, and Redis store.
module Lita
  # The base Redis namespace for all Lita data.
  REDIS_NAMESPACE = "lita"

  class << self
    # The global registry of adapters.
    # @return [Hash] A map of adapter keys to adapter classes.
    def adapters
      @adapters ||= {}
    end

    # Adds an adapter to the global registry under the provided key.
    # @param key [String, Symbol] The key that identifies the adapter.
    # @param adapter [Lita::Adapter] The adapter class.
    # @return [void]
    def register_adapter(key, adapter)
      adapters[key.to_sym] = adapter
    end

    # The global registry of handlers.
    # @return [Set] The set of handlers.
    def handlers
      @handlers ||= Set.new
    end

    # Adds a handler to the global registry.
    # @param handler [Lita::Handler] The handler class.
    # @return [void]
    def register_handler(handler)
      handlers << handler
    end

    # The global configuration object. Provides user settings for the robot.
    # @return [Lita::Config] The Lita configuration object.
    def config
      @config ||= Config.default_config
    end

    # Yields the global configuration object. Called by the user in a
    # lita_config.rb file.
    # @yieldparam [Lita::Configuration] config The global configuration object.
    # @return [void]
    def configure
      yield config
    end

    # Clears the global configuration object. The next call to {Lita.config}
    # will create a fresh config object.
    # @return [void]
    def clear_config
      @config = nil
    end

    # The global Logger object.
    # @return [::Logger] The global Logger object.
    def logger
      @logger ||= Logger.get_logger(Lita.config.robot.log_level)
    end

    # The root Redis object.
    # @return [Redis::Namespace] The root Redis object.
    def redis
      @redis ||= begin
        redis = Redis.new(config.redis)
        Redis::Namespace.new(REDIS_NAMESPACE, redis: redis)
      end
    end

    # Loads user configuration and starts the robot.
    # @param config_path [String] The path to the user configuration file.
    # @return [void]
    def run(config_path = nil)
      Config.load_user_config(config_path)
      Robot.new.run
    end
  end
end

require "lita/util"
require "lita/daemon"
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
