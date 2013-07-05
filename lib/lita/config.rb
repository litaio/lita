module Lita
  # An object that stores various user settings that affect Lita's behavior.
  class Config < Hash
    class << self
      # Initializes a new Config object with the default settings.
      # @return [Lita::Config] The default configuration.
      def default_config
        config = new.tap do |c|
          c.robot = new
          c.robot.name = "Lita"
          c.robot.adapter = :shell
          c.robot.log_level = :info
          c.robot.admins = nil
          c.redis = new
          c.http = new
          c.http.port = 8080
          c.http.debug = false
          c.adapter = new
          c.handlers = new
        end
        load_handler_configs(config)
        config
      end

      # Loads configuration from a user configuration file.
      # @param config_path [String] The path to the configuration file.
      # @return [void]
      def load_user_config(config_path = nil)
        config_path = "lita_config.rb" unless config_path

        begin
          load(config_path)
        rescue Exception => e
          Lita.logger.fatal <<-MSG
Lita configuration file could not be processed. The exception was:
#{e.message}
#{e.backtrace.join("\n")}
MSG
          abort
        end if File.exist?(config_path)
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
