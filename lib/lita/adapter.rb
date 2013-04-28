module Lita
  class Adapter
    def self.load_adapter(key)
      Lita.adapters[key.to_sym] or
        raise UnknownAdapterError.new(%{Adapter "#{key}" not registered.})
    end

    attr_reader :robot, :stdout, :stdin

    def initialize(robot, config, options = {})
      @robot = robot
      @config = config
      @stdout = options[:stdout] || $stdout
      @stdin = options[:stdin] || $stdin
    end
  end
end
