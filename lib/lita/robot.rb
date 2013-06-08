require "forwardable"

module Lita
  class Robot
    extend Forwardable

    attr_reader :name

    def_delegators :@adapter, :say

    def initialize
      @name = Lita.config.robot.name
      adapter_name = Lita.config.adapter.name
      adapter_class = Lita.adapters[adapter_name]
      raise "Unknown adapter: #{adapter_name}" unless adapter_class
      @adapter = adapter_class.new(self)
    end

    def run
      @adapter.run
    end

    def receive(message)
      Lita.handlers.each { |handler| handler.dispatch(self, message) }
    end
  end
end
