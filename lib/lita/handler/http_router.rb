module Lita
  class Handler
    # A handler mixin that provides the methods necessary for handling incoming HTTP requests.
    # @since 4.0.0
    module HTTPRouter
      # Includes common handler methods in any class that includes {HTTPRouter}.
      def self.extended(klass)
        klass.send(:include, Common)
      end

      # Creates a new {Lita::HTTPRoute} which is used to define an HTTP route
      # for the built-in web server.
      # @see Lita::HTTPRoute
      # @return [Lita::HTTPRoute] The new {Lita::HTTPRoute}.
      def http
        HTTPRoute.new(self)
      end

      # An array of all HTTP routes defined for the handler.
      # @return [Array<Lita::HTTPRoute>] The array of routes.
      def http_routes
        @http_routes ||= []
      end
    end
  end
end
