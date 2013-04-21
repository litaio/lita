module Lita
  class << self
    def run
      Robot.new(load_config).run
    end

    def adapters
      @adapters ||= {}
    end

    def listeners
      @listeners ||= []
    end

    def commands
      @commands ||= []
    end

    def configure
      yield config
      config
    end

    def config
      @config ||= Config.default_config
    end

    def load_config
      config_path = File.expand_path("lita_config.rb", Dir.pwd)

      begin
        load(config_path)
      rescue Exception => e
        abort <<-ERROR
Lita could not load due to an exception raised in lita_config.rb:
#{e.class}: #{e.message}
#{e.backtrace.join("\n")}
ERROR
      end if File.exist?(config_path)

      config
    end
  end
end

require "lita/version"
require "lita/errors"
require "lita/config"
require "lita/robot"
require "lita/listener"
require "lita/command"
