# Primary class from the +http_router+ gem.
# @todo Remove this monkey patch as soon as a gem is released with this pull request merged:
#   https://github.com/joshbuddy/http_router/pull/40
class HttpRouter
  # An individual HTTP route.
  class Route
    # Sets a name for the route. Monkey patched due to a bug.
    def name=(name)
      @name = name
      router.named_routes[name] << self if router
    end
  end
end

module Lita
  # Handlers use this class to define HTTP routes for the built-in web
  # server.
  class HTTPRoute
    # An +HttpRouter::Route+ class used for dispatch.
    # @since 3.0.0
    ExtendedRoute = Class.new(HttpRouter::Route) do
      include HttpRouter::RouteHelper
      include HttpRouter::GenerationHelper
    end

    # The handler registering the route.
    # @return [Lita::Handler] The handler.
    attr_reader :handler_class

    # @param handler_class [Lita::Handler] The handler registering the route.
    def initialize(handler_class)
      @handler_class = handler_class
    end

    class << self
      private

      # @!macro define_http_method
      #   @overload $1(path, method_name, options = {})
      #     Defines a new route with the "$1" HTTP method.
      #     @param path [String] The URL path component that will trigger the route.
      #     @param method_name [Symbol, String] The name of the instance method in
      #       the handler to call for the route.
      #     @param options [Hash] Various options for controlling the behavior of the route.
      #     @return [void]
      #   @overload $1(path, options = {})
      #     Defines a new route with the "$1" HTTP method.
      #     @param path [String] The URL path component that will trigger the route.
      #     @param options [Hash] Various options for controlling the behavior of the route.
      #     @yield The body of the route's callback.
      #     @return [void]
      #     @since 4.0.0
      def define_http_method(http_method)
        define_method(http_method) do |path, method_name = nil, options = {}, &block|
          register_route(http_method.to_s.upcase, path, Callback.new(method_name || block), options)
        end
      end
    end

    define_http_method :head
    define_http_method :get
    define_http_method :post
    define_http_method :put
    define_http_method :patch
    define_http_method :delete
    define_http_method :options
    define_http_method :link
    define_http_method :unlink

    private

    # Adds a new HTTP route for the handler.
    def register_route(http_method, path, callback, options)
      route = new_route(http_method, path, callback, options)
      route.to(HTTPCallback.new(handler_class, callback))
      handler_class.http_routes << route
    end

    # Creates and configures a new HTTP route.
    def new_route(http_method, path, callback, options)
      route = ExtendedRoute.new
      route.path = path
      route.name = callback.method_name
      route.add_match_with(options)
      route.add_request_method(http_method)
      route.add_request_method("HEAD") if http_method == "GET"
      route
    end
  end
end
