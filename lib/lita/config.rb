module Lita
  # An object that stores various user settings that affect Lita's behavior.
  # @deprecated Will be removed in Lita 5.0. Use {Lita::ConfigurationBuilder} instead.
  class Config < Hash
    class << self
      # Initializes a new Config object with the default settings.
      # @return [Lita::Config] The default configuration.
      def default_config
        new.tap do |c|
          load_robot_configs(c)
          c.redis = new
          load_http_configs(c)
          c.adapter = new
          c.handlers = new
          load_handler_configs(c)
        end
      end

      private

      # Adds and populates a Config object to Lita.config.handlers for every
      # registered handler that implements self.default_config.
      def load_handler_configs(config)
        Lita.handlers.each do |handler|
          next unless handler.respond_to?(:default_config)
          handler_config = config.handlers[handler.namespace] = new
          handler.default_config(handler_config)
        end
      end

      # Adds and populates a Config object for the built-in web server.
      def load_http_configs(config)
        config.http = new
        config.http.host = "0.0.0.0"
        config.http.port = 8080
        config.http.min_threads = 0
        config.http.max_threads = 16
      end

      # Adds and populates a Config object for the Robot.
      def load_robot_configs(config)
        config.robot = new
        config.robot.name = "Lita"
        config.robot.adapter = :shell
        config.robot.locale = I18n.locale
        config.robot.log_level = :info
        config.robot.admins = nil
      end
    end

    # Sets a config key.
    # @param key [Symbol, String] The key.
    # @param value The value.
    # @return The value.
    def []=(key, value)
      super(key.to_sym, value)
    end

    # Get a config key.
    # @param key [Symbol, String] The key.
    # @return The value.
    def [](key)
      super(key.to_sym)
    end

    # Deeply freezes the object to prevent any further mutation.
    # @return [void]
    # @since 3.0.0
    def finalize
      IceNine.deep_freeze!(self)
    end

    # Allows keys to be read and written with struct-like syntax.
    def method_missing(name, *args)
      name_string = name.to_s
      if name_string.chomp!("=")
        self[name_string] = args.first
      else
        self[name_string]
      end
    end
  end
end
