module Lita
  class Config < Hash
    class << self
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
          c.adapter = new
          c.handlers = new
        end
        load_handler_configs(config)
        config
      end

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

      def load_handler_configs(config)
        Lita.handlers.each do |handler|
          next unless handler.respond_to?(:default_config)
          handler_config = config.handlers[handler.namespace] = new
          handler.default_config(handler_config)
        end
      end
    end

    def []=(key, value)
      super(key.to_sym, value)
    end

    def [](key)
      super(key.to_sym)
    end

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
