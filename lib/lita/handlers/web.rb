module Lita
  module Handlers
    class Web < Handler
      http.get "/lita/info", :info

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
