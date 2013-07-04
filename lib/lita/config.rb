module Lita
  class Config < Hash
    def self.default_config
      new.tap do |c|
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
    end

    def self.load_user_config(config_path = nil)
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
