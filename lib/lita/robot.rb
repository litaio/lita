require "lita/adapter/shell"
require "lita/storage"

module Lita
  class Robot
    extend Forwardable

    def_delegators :@adapter, :run, :say
    def_delegators :@storage, :get, :set

    def initialize
      @adapter = Adapter::Shell.new(self)
      @storage = Storage.new
    end

    def receive(message)
      listeners.each { |listener| listener.new(self).call(message) }
    end

    private

    def listeners
      Lita.listeners
    end
  end
end
