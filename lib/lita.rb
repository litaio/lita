require "forwardable"
require "logger"
require "rbconfig"
require "readline"
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

require_relative "lita/registry"

# The main namespace for Lita. Provides a global registry of adapters and
# handlers, as well as global configuration, logger, and Redis store.
module Lita
  # The base Redis namespace for all Lita data.
  REDIS_NAMESPACE = "lita"

  class << self
    include Registry::Mixins

    # A special mode to ensure that tests written for Lita 3 plugins continue to work.
    # @return [Boolean] Whether or not version 3 compatibility mode is active.
    # @since 4.0.0
    attr_accessor :version_3_compatibility_mode
    alias_method :version_3_compatibility_mode?, :version_3_compatibility_mode

    # A mode that makes minor changes to the Lita runtime to improve testability.
    # @return [Boolean] Whether or not test mode is active.
    # @since 4.0.0
    attr_accessor :test_mode
    alias_method :test_mode?, :test_mode

    # The global Logger object.
    # @return [::Logger] The global Logger object.
    def logger
      @logger ||= Logger.get_logger(config.robot.log_level)
    end

    # The root Redis object.
    # @return [Redis::Namespace] The root Redis object.
    def redis
      @redis ||= begin
        redis = Redis.new(config.redis)
        Redis::Namespace.new(REDIS_NAMESPACE, redis: redis).tap do |client|
          begin
            client.ping
          rescue Redis::BaseError => e
            if Lita.test_mode?
              raise RedisError, I18n.t("lita.redis.test_mode_exception", message: e.message)
            else
              Lita.logger.fatal I18n.t(
                "lita.redis.exception",
                message: e.message,
                backtrace: e.backtrace.join("\n")
              )
              abort
            end
          end
        end
      end
    end

    # Loads user configuration and starts the robot.
    # @param config_path [String] The path to the user configuration file.
    # @return [void]
    def run(config_path = nil)
      hooks[:before_run].each { |hook| hook.call(config_path: config_path) }
      ConfigurationBuilder.load_user_config(config_path)
      ConfigurationBuilder.freeze_config(config)
      ConfigurationValidator.new(self).call
      hooks[:config_finalized].each { |hook| hook.call(config_path: config_path) }
      self.locale = config.robot.locale
      Robot.new.run
    end
  end
end

require_relative "lita/version"
require_relative "lita/common"
require_relative "lita/errors"
require_relative "lita/config"
require_relative "lita/configuration_builder"
require_relative "lita/middleware_registry"
require_relative "lita/default_configuration"
require_relative "lita/configuration_validator"
require_relative "lita/util"
require_relative "lita/logger"
require_relative "lita/callback"
require_relative "lita/configurable"
require_relative "lita/namespace"
require_relative "lita/template"
require_relative "lita/template_resolver"
require_relative "lita/handler/common"
require_relative "lita/handler/chat_router"
require_relative "lita/handler/http_router"
require_relative "lita/handler/event_router"
require_relative "lita/handler"
require_relative "lita/user"
require_relative "lita/source"
require_relative "lita/authorization"
require_relative "lita/message"
require_relative "lita/response"
require_relative "lita/http_callback"
require_relative "lita/http_route"
require_relative "lita/rack_app"
require_relative "lita/timer"
require_relative "lita/robot"
require_relative "lita/adapter"
require_relative "lita/adapters/shell"
require_relative "lita/plugin_builder"
require_relative "lita/route_validator"
require_relative "lita/handlers/authorization"
require_relative "lita/handlers/help"
require_relative "lita/handlers/info"
require_relative "lita/handlers/room"
require_relative "lita/handlers/users"
require_relative "lita/handlers/deprecation_check"
