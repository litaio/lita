require "lita/adapter/shell"

module Lita
  class Robot
    extend Forwardable

    def_delegators :@adapter, :run, :say

    def initialize
      @adapter = Adapter::Shell.new(self)
    end

    def receive(message)
      listeners.each { |listener| listener.call(self, message) }
    end

    private

    def listeners
      Lita.listeners
    end
  end
end
