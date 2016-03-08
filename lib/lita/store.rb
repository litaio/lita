require "thread"

module Lita
  # A simple, in-memory, thread-safe key-value store.
  # @since 5.0.0
  class Store
    # @param internal_store [Hash] A hash-like object to use internally to store data.
    def initialize(internal_store = {})
      @store = internal_store
      @lock = Mutex.new
    end

    # Get a key from the store.
    def [](key)
      @lock.synchronize { @store[key] }
    end

    # Set a key to the given value.
    def []=(key, value)
      @lock.synchronize { @store[key] = value }
    end
  end
end
