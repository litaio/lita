module Lita
  class DefaultConfiguration
    LOG_LEVELS = %i(debug info warn error fatal)

    attr_reader :registry
    attr_reader :root

    def initialize(registry)
      @registry = registry
      @root = Configuration.new

      adapters_config
      handlers_config
      http_config
      redis_config
      robot_config
    end

    def finalize
      final_config = root.finalize
      add_adapter_attribute(final_config)
      final_config
    end

    private

    def adapters_config
      adapters_with_configuration = registry.adapters.select do |_key, adapter|
        adapter.configuration
      end

      root.config :adapters do
        adapters_with_configuration.each do |key, adapter|
          config(key, &adapter.configuration)
        end
      end unless adapters_with_configuration.empty?
    end

    def add_adapter_attribute(config)
      def config.adapter
        @adapter ||= begin
          Lita.logger.warn(I18n.t("lita.config.adapter_deprecated"))
          Config.new
        end
      end
    end

    def handlers_config
      handlers_with_configuration = registry.handlers.select { |handler| handler.configuration }

      root.config :handlers do
        handlers_with_configuration.each do |handler|
          config(handler.namespace, &handler.configuration)
        end
      end unless handlers_with_configuration.empty?
    end

    def http_config
      root.config :http do
        config :host, type: String, default: "0.0.0.0"
        config :port, type: Integer, default: 8080
        config :min_threads, type: Integer, default: 0
        config :max_threads, type: Integer, default: 16
      end
    end

    def redis_config
      root.config :redis, type: Hash, default: {}
    end

    def robot_config
      root.config :robot do
        config :name, type: String, default: "Lita"
        config :mention_name, type: String
        config :alias, type: String
        config :adapter, types: [String, Symbol], default: :shell
        config :locale, types: [String, Symbol], default: I18n.locale
        config :log_level, types: [String, Symbol], default: :info do
          validate do |value|
            "log_level must be one of: #{LOG_LEVELS.join(", ")}" unless LOG_LEVELS.include?(value)
          end
        end
        config :admins
      end
    end
  end
end
