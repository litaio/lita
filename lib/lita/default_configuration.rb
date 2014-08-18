module Lita
  class DefaultConfiguration
    LOG_LEVELS = %i(debug info warn error fatal)

    attr_reader :root

    def initialize
      @root = Configuration.new
      adapter_config
      adapters_config
      handlers_config
      http_config
      redis_config
      robot_config
    end

    def finalize
      root.finalize
    end

    private

    def adapter_config
      root.config :adapter, type: Config, default: Config.new
    end

    def adapters_config
    end

    def handlers_config
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
