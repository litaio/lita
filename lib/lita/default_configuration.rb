# frozen_string_literal: true

require_relative "configuration_builder"
require_relative "middleware_registry"

module Lita
  # Builds the configuration object that is stored in each {Registry}.
  # @since 4.0.0
  # @api private
  class DefaultConfiguration
    # Valid levels for Lita's logger.
    LOG_LEVELS = %w[debug info warn error fatal].freeze

    # The default log formatter.
    #
    # This is specified as a constant instead of inline for +config.robot.log_formatter+ so it can
    # be used by {Lita.logger} for early logging without accessing it via the config attribute and
    # generating the default config too early, before plugins have been registered.
    DEFAULT_LOG_FORMATTER = lambda { |severity, datetime, _progname, msg|
      "[#{datetime.utc}] #{severity}: #{msg}\n"
    }

    # A {Registry} to extract configuration for plugins from.
    # @return [Registry] The registry.
    attr_reader :registry

    # The top-level {ConfigurationBuilder} attribute.
    # @return [Configuration] The root attribute.
    attr_reader :root

    # @param registry [Registry] The registry to build a default configuration object from.
    def initialize(registry)
      @registry = registry
      @root = ConfigurationBuilder.new

      adapters_config
      handlers_config
      http_config
      redis_config
      robot_config
    end

    # Processes the {ConfigurationBuilder} object to return a {Configuration}.
    # @return [Configuration] The built configuration object.
    def build
      root.build
    end

    private

    # Builds config.adapters
    def adapters_config
      adapters = registry.adapters

      root.config :adapters do
        adapters.each do |key, adapter|
          combine(key, adapter.configuration_builder)
        end
      end
    end

    # Builds config.handlers
    def handlers_config
      handlers = registry.handlers

      root.config :handlers do
        handlers.each do |handler|
          if handler.configuration_builder.children?
            combine(handler.namespace, handler.configuration_builder)
          end
        end
      end
    end

    # Builds config.http
    def http_config
      root.config :http do
        config :host, type: String, default: "0.0.0.0"
        config :port, type: [Integer, String], default: 8080
        config :min_threads, type: [Integer, String], default: 0
        config :max_threads, type: [Integer, String], default: 16
        config :middleware, type: MiddlewareRegistry, default: MiddlewareRegistry.new
      end
    end

    # Builds config.redis
    def redis_config
      root.config :redis, type: Hash, default: {}
    end

    # Builds config.robot
    def robot_config
      root.config :robot do
        config :name, type: String, default: "Lita"
        config :mention_name, type: String
        config :alias, type: String
        config :adapter, types: [String, Symbol], default: :shell
        config :locale, types: [String, Symbol], default: nil
        config :default_locale, types: [String, Symbol], default: nil
        config :redis_namespace, type: String, default: Lita.test_mode? ? "lita.test" : "lita"
        config :log_level, types: [String, Symbol], default: :info do
          validate do |value|
            unless LOG_LEVELS.include?(value.to_s.downcase.strip)
              "must be one of: #{LOG_LEVELS.join(", ")}"
            end
          end
        end
        config :log_formatter, default: DEFAULT_LOG_FORMATTER do
          validate do |value|
            "must respond to #call" unless value.respond_to?(:call)
          end
        end
        config :admins
        config :error_handler, default: ->(_error, _metadata) {} do
          validate do |value|
            "must respond to #call" unless value.respond_to?(:call)
          end
        end
      end
    end
  end
end
