module Lita
  # Stores Rack middleware for later use in a +Rack::Builder+.
  # @since 4.0.2
  # @api private
  class MiddlewareRegistry
    # A Rack middleware and its initialization arguments.
    class MiddlewareWrapper < Struct.new(:middleware, :args, :block); end

    extend Forwardable

    def_delegators :@registry, :each, :empty?

    def initialize
      @registry = []
    end

    # Adds a Rack middleware with no initialization arguments.
    # @param middleware [#call] A Rack middleware.
    # @return [void]
    def push(middleware)
      @registry << MiddlewareWrapper.new(middleware, [], nil)
    end
    alias_method :<<, :push

    # Adds a Rack middleware with initialization argumens. Uses the same interface as
    # +Rack::Builder#use+.
    # @param middleware [#call] A Rack middleware.
    # @param args [Array] Arbitrary initialization arguments for the middleware.
    # @yield An optional block to be passed to the constructor of the middleware.
    # @return [void]
    def use(middleware, *args, &block)
      @registry << MiddlewareWrapper.new(middleware, args, block)
    end
  end
end
