# HACK! Make a pull request against HttpRouter. VALID_HTTP_VERBS should be consistent with
# helper methods provided. It should also look up the constant in custom route classes, if defined.
HttpRouter::Route::VALID_HTTP_VERBS.replace(%w(HEAD GET POST PUT PATCH DELETE OPTIONS LINK UNLINK))

module Lita
  # Handlers use this class to define HTTP routes for the built-in web
  # server.
  class HTTPRoute
    # An +HttpRouter::Route+ class used for dispatch.
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
      #   @method $1(path, method_name)
      #   Defines a new route with the "$1" HTTP method.
      #   @param path [String] The URL path component that will trigger the
      #     route.
      #   @param method_name [Symbol, String] The name of the instance method in
      #     the handler to call for the route.
      #   @return [void]
      def define_http_method(http_method)
        define_method(http_method) do |path, method_name|
          create_route(http_method.to_s.upcase, path, method_name)
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

    # Creates a new HTTP route.
    def create_route(http_method, path, method_name)
      route = ExtendedRoute.new
      route.path = path
      route.add_request_method(http_method)
      route.add_request_method("HEAD") if http_method == "GET"

      route.to do |env|
        request = Rack::Request.new(env)
        response = Rack::Response.new

        if request.head?
          response.status = 204
        else
          handler_class.new(env["lita.robot"]).public_send(method_name, request, response)
        end

        response.finish
      end

      handler_class.http_routes << route
    end
  end
end
