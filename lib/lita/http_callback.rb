require "rack"

module Lita
  # A wrapper around a handler's HTTP route callbacks that sets up the request and response.
  # @api private
  # @since 4.0.0
  class HTTPCallback
    # @param handler_class [Handler] The handler defining the callback.
    # @param callback [Proc] The callback.
    def initialize(handler_class, callback)
      @handler_class = handler_class
      @callback = callback
    end

    # Call the Rack endpoint with a standard environment hash.
    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new

      if request.head?
        response.status = 204
      else
        begin
          handler = @handler_class.new(env["lita.robot"])

          @callback.call(handler, request, response)
        rescue => e
          robot = env["lita.robot"]
          error_handler = robot.config.robot.error_handler

          if error_handler.arity == 2
            error_handler.call(e, rack_env: env, robot: robot)
          else
            error_handler.call(error)
          end

          raise
        end
      end

      response.finish
    end
  end
end
