# frozen_string_literal: true

require "stringio"

require "i18n"
require "i18n/backend/fallbacks"
require "redis-namespace"

require_relative "lita/configuration_builder"
require_relative "lita/configuration_validator"
require_relative "lita/errors"
require_relative "lita/logger"
require_relative "lita/registry"
require_relative "lita/robot"

# The main namespace for Lita. Provides a global registry of adapters and
# handlers, as well as global configuration, logger, and Redis store.
module Lita
  class << self
    include Registry::Mixins

    # A mode that makes minor changes to the Lita runtime to improve testability.
    # @return [Boolean] Whether or not test mode is active.
    # @since 4.0.0
    attr_reader :test_mode
    alias test_mode? test_mode

    # Sets both I18n.default_locale and I18n.locale to the provided locale, if any.
    # @api private
    # @since 5.0.0
    def configure_i18n(new_locale)
      unless new_locale.nil?
        self.default_locale = new_locale
        self.locale = new_locale
      end
    end

    # Lita's global +Logger+.
    #
    # The log level is initially set according to the environment variable +LITA_LOG+, defaulting to
    # +info+ if the variable is not set. Once the user configuration is loaded, the log level will
    # be reset to whatever is specified in the configuration file.
    # @return [::Logger] A +Logger+ object.
    def logger
      @logger ||= Logger.get_logger(
        ENV["LITA_LOG"],
        io: test_mode? ? StringIO.new : $stderr,
      )
    end

    # Adds one or more paths to the I18n load path and reloads I18n.
    # @param paths [String, Array<String>] The path(s) to add.
    # @return [void]
    # @since 3.0.0
    def load_locales(paths)
      I18n.load_path.concat(Array(paths))
      I18n.reload!
    end

    # Sets +I18n.locale+, normalizing the provided locale name.
    #
    # Note that setting this only affects the current thread. Since handler
    # methods are dispatched in new threads, changing the locale globally will
    # require calling this method at the start of every handler method.
    # Alternatively, use {Lita#default_locale=} which will affect all threads.
    # @param new_locale [Symbol, String] The code of the locale to use.
    # @return [void]
    # @since 3.0.0
    def locale=(new_locale)
      I18n.locale = new_locale.to_s.tr("_", "-")
    end

    # Sets +I18n.default_locale+, normalizing the provided locale name.
    #
    # This is preferred over {Lita#locale=} as it affects all threads.
    # @param new_locale [Symbol, String] The code of the locale to use.
    # @return [void]
    # @since 4.8.0
    def default_locale=(new_locale)
      I18n.default_locale = new_locale.to_s.tr("_", "-")
    end

    # The absolute path to Lita's templates directory.
    # @return [String] The path.
    # @since 3.0.0
    def template_root
      File.expand_path("../templates", __dir__)
    end

    # Loads user configuration.
    # @param config_path [String] The path to the user configuration file.
    # @return [void]
    def load_config(config_path = nil)
      hooks[:before_run].each { |hook| hook.call(config_path: config_path) }
      ConfigurationBuilder.load_user_config(config_path)
      ConfigurationBuilder.freeze_config(config)
      recreate_logger # Pick up value of `config.robot.log_level` and `config.robot.log_formatter`.
      ConfigurationValidator.new(self).call
      hooks[:config_finalized].each { |hook| hook.call(config_path: config_path) }

      if config.robot.default_locale || config.robot.locale
        logger.warn I18n.t("lita.config.locale_deprecated")
        self.default_locale = config.robot.default_locale if config.robot.default_locale
        self.locale = config.robot.locale if config.robot.locale
      end
    end

    # Loads user configuration and starts the robot.
    # @param config_path [String] The path to the user configuration file.
    # @return [void]
    def run(config_path = nil)
      load_config(config_path)
      Robot.new.run
    end

    # Turns test mode on or off.
    # @param mode [Boolean] Whether or not test mode should be enabled.
    # @return [void]
    # @see #test_mode
    def test_mode=(mode)
      @test_mode = mode
      # Reset the logger because its IO stream is determined by test mode.
      recreate_logger
    end

    # A special mode to ensure that tests written for Lita 3 plugins continue to work. Has no effect
    # in Lita 5+.
    # @return [Boolean] Whether or not version 3 compatibility mode is active.
    # @since 4.0.0
    # @deprecated Will be removed in Lita 6.0.
    def version_3_compatibility_mode(_value = nil)
      warn I18n.t("lita.rspec.lita_3_compatibility_mode")
      false
    end
    alias version_3_compatibility_mode? version_3_compatibility_mode
    alias version_3_compatibility_mode= version_3_compatibility_mode

    private

    # Recreate the logger, specifying the configured log level and output stream. Should be called
    # manually after user configuration has been loaded and whenever test mode is changed. This is
    # necessary because {#logger} does not access the config so as not to accidentally build the
    # {DefaultConfiguration} before all plugins have been loaded and registered.
    def recreate_logger
      @logger = Logger.get_logger(
        config.robot.log_level,
        formatter: config.robot.log_formatter,
        io: test_mode? ? StringIO.new : $stderr,
      )
    end
  end
end

I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
I18n.enforce_available_locales = false
Lita.load_locales(Dir[File.join(Lita.template_root, "locales", "*.yml")])
Lita.configure_i18n(ENV["LC_ALL"] || ENV["LC_MESSAGES"] || ENV["LANG"])

require_relative "lita/adapters/shell"
require_relative "lita/adapters/test"

require "lita-default-handlers"
