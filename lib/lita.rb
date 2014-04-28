require "forwardable"
require "logger"
require "rbconfig"
require "set"
require "shellwords"
require "thread"

require "http_router"
require "ice_nine"
require "faraday"
require "multi_json"
require "puma"
require "rack"
require "redis-namespace"

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

    # The global registry of hook handler objects.
    # @return [Hash] A hash mapping hook names to sets of objects that handle them.
    # @since 3.2.0
    def hooks
      @hooks ||= Hash.new { |h, k| h[k] = Set.new }
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

    # Adds a hook handler object to the global registry for the given hook.
    # @return [void]
    # @since 3.2.0
    def register_hook(name, hook)
      hooks[name.to_s.downcase.strip.to_sym] << hook
    end

    # Loads user configuration and starts the robot.
    # @param config_path [String] The path to the user configuration file.
    # @return [void]
    def run(config_path = nil)
      Config.load_user_config(config_path)
      Lita.config.finalize
      self.locale = Lita.config.robot.locale
      Robot.new.run
    end
  end
end

require_relative "lita/version"
require_relative "lita/common"
require_relative "lita/config"
require_relative "lita/util"
require_relative "lita/logger"
require_relative "lita/user"
require_relative "lita/source"
require_relative "lita/authorization"
require_relative "lita/message"
require_relative "lita/response"
require_relative "lita/http_route"
require_relative "lita/rack_app"
require_relative "lita/timer"
require_relative "lita/robot"
require_relative "lita/adapter"
require_relative "lita/adapters/shell"
require_relative "lita/handler"
require_relative "lita/handlers/authorization"
require_relative "lita/handlers/help"
require_relative "lita/handlers/info"
require_relative "lita/handlers/room"
