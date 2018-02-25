# frozen_string_literal: true

require_relative "../http_route"
require_relative "common"

module Lita
  class Handler
    # A handler mixin that provides the methods necessary for handling incoming HTTP requests.
    # @since 4.0.0
    module HTTPRouter
      # Includes common handler methods in any class that includes {HTTPRouter}.
      def self.extended(klass)
        klass.send(:include, Common)
      end

      # Creates a new {HTTPRoute} which is used to define an HTTP route
      # for the built-in web server.
      # @see HTTPRoute
      # @return [HTTPRoute] The new {HTTPRoute}.
      def http
        HTTPRoute.new(self)
      end

      # An array of all HTTP routes defined for the handler.
      # @return [Array<HTTPRoute>] The array of routes.
      def http_routes
        @http_routes ||= []
      end
    end
  end
end
