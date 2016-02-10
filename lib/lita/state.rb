require_relative "common"

module Lita
  class State
    # A handler class that gives in-memory, non-persited, object storage
    # @since 5.0.0
    attr_reader :store, :lock

    # Instantiate a State object and it's internal dependencies.
    def initialize
      @store ||= {}
      @lock = Mutex.new
    end

    # Returns the value of the internal store at a given key
    # @param key [String, Symbol] The name of the key for which you want a value
    # @return [Object] The value of the key
    # @since 5.0.0
    def get(key)
      lock.synchronize { store[key.to_s.downcase.tr(" ", "_").to_sym] }
    end

    # Sets the value of the internal store for a given key value pair
    # @param key [String, Symbol] The name of the key
    # @param value [Object] the object to be stored
    # @since 5.0.0
    def set(key, value)
      lock.synchronize { store[key.to_s.downcase.tr(" ", "_").to_sym] = value }
    end

    private

    # Gives the handler threadsafe
    # @yield threadsafe operations involving the state storage
    # @return [Object] the result of the block
    # @since 5.0.0
    def synchronize(&block)
      lock.synchronize do
        yield if block
      end
    end
  end
end
