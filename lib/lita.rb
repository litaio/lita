module Lita
  def self.run
    Robot.new(load_config).run
  end

  def self.config
    @config ||= Config.default_config
  end

  def self.configure
    yield config
  end

  def self.load_config
    config_path = File.expand_path("lita_config.rb", Dir.pwd)

    begin
      load(config_path)
    rescue Exception
      raise ConfigError
    end if File.exist?(config_path)

    config
  end

  def self.adapters
    @adapters ||= {}
  end

  def self.listeners
    @listeners ||= []
  end

  def self.commands
    @commands ||= []
  end
end

require "lita/errors"
require "lita/robot"
require "lita/config"
