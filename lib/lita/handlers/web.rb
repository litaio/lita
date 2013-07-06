module Lita
  module Handlers
    # Provides an HTTP route with basic information about the running robot.
    class Web < Handler
      http.get "/lita/info", :info

      # Returns JSON with basic information about the robot.
      # @param request [Rack::Request] The HTTP request.
      # @param response [Rack::Response] The HTTP response.
      # @return [void]
      def info(request, response)
        response.headers["Content-Type"] = "application/json"
        json = MultiJson.dump(
          lita_version: Lita::VERSION,
          adapter: Lita.config.robot.adapter,
          robot_name: robot.name,
          robot_mention_name: robot.mention_name
        )
        response.write(json)
      end
    end

    Lita.register_handler(Web)
  end
end
