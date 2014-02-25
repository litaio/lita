module Lita
  # A namespace to hold all subclasses of {Handler}.
  module Handlers
    # Provides information about the currently running robot.
    class Info < Handler
      route(/^info$/i, :chat, command: true, help: {
        "info" => t("help.info_value")
      })

      http.get "/lita/info", :web

      # Replies with the current version of the Lita.
      # @param response [Lita::Response] The response object.
      # @return [void]
      def chat(response)
        response.reply "Lita #{Lita::VERSION} - http://www.lita.io/"
      end

      # Returns JSON with basic information about the robot.
      # @param request [Rack::Request] The HTTP request.
      # @param response [Rack::Response] The HTTP response.
      # @return [void]
      def web(request, response)
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

    Lita.register_handler(Info)
  end
end
