module Lita
  class << self
    def run
      Robot.new(config).run
    end

    def listeners
      @listeners ||= []
    end

    def configure
      yield config
      config
    end

    def config
      @config ||= Config.default_config
    end
  end
end

require "lita/version"
require "lita/config"
require "lita/robot"
require "lita/listener"
