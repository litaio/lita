require "i18n"
require "redis-namespace"

require_relative "lita/common"
require_relative "lita/configuration_builder"
require_relative "lita/configuration_validator"
require_relative "lita/errors"
require_relative "lita/logger"
require_relative "lita/registry"
require_relative "lita/robot"

# The main namespace for Lita. Provides a global registry of adapters and
# handlers, as well as global configuration, logger, and Redis store.
module Lita
  # The base Redis namespace for all Lita data.
  REDIS_NAMESPACE = "lita".freeze

  class << self
    include Registry::Mixins

    # A mode that makes minor changes to the Lita runtime to improve testability.
    # @return [Boolean] Whether or not test mode is active.
    # @since 4.0.0
    attr_accessor :test_mode
    alias test_mode? test_mode

    # A global logger. Initialized before configuration so it doesn't respect log-related Lita
    # configuration. The log level defaults to :info and can be set by invoking the process with the
    # environment variable LITA_GLOBAL_LOG_LEVEL set to one of the standard log level names.
    attr_accessor :logger

    # Loads user configuration.
    # @param config_path [String] The path to the user configuration file.
    # @return [void]
    def load_config(config_path = nil)
      hooks[:before_run].each { |hook| hook.call(config_path: config_path) }
      ConfigurationBuilder.load_user_config(config_path)
      ConfigurationBuilder.freeze_config(config)
      ConfigurationValidator.new(self).call
      hooks[:config_finalized].each { |hook| hook.call(config_path: config_path) }
      self.locale = config.robot.locale
    end

    # Loads user configuration and starts the robot.
    # @param config_path [String] The path to the user configuration file.
    # @return [void]
    def run(config_path = nil)
      load_config(config_path)
      Robot.new.run
    end

    # A special mode to ensure that tests written for Lita 3 plugins continue to work. Has no effect
    # in Lita 5+.
    # @return [Boolean] Whether or not version 3 compatibility mode is active.
    # @since 4.0.0
    # @deprecated Will be removed in Lita 6.0.
    def version_3_compatibility_mode(_value = nil)
      warn I18n.t("lita.rspec.lita_3_compatibility_mode")
    end
    alias version_3_compatibility_mode? version_3_compatibility_mode
    alias version_3_compatibility_mode= version_3_compatibility_mode
  end

  self.logger = Logger.get_logger(ENV["LITA_GLOBAL_LOG_LEVEL"], nil)
end

require_relative "lita/adapters/shell"
require_relative "lita/adapters/test"

require "lita-default-handlers"
