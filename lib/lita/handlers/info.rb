module Lita
  # A namespace to hold all subclasses of {Handler}.
  module Handlers
    # Provides information about the currently running robot.
    class Info < Handler
      route(/^info$/i, :chat, command: true, help: {
        "info" => t("help.info_value")
      })

      http.get "/lita/info", :web

      # Replies with the current version of Lita, the current version of Redis,
      # and Redis memory usage.
      # @param response [Lita::Response] The response object.
      # @return [void]
      # @since 3.0.0
      def chat(response)
        response.reply(
          %(Lita #{Lita::VERSION} - https://www.lita.io/),
          %(Redis #{redis_version} - Memory used: #{redis_memory_usage})
        )
      end

      # Returns JSON with basic information about the robot.
      # @param _request [Rack::Request] The HTTP request.
      # @param response [Rack::Response] The HTTP response.
      # @return [void]
      def web(_request, response)
        response.headers["Content-Type"] = "application/json"
        json = MultiJson.dump(
          adapter: robot.config.robot.adapter,
          lita_version: Lita::VERSION,
          redis_memory_usage: redis_memory_usage,
          redis_version: redis_version,
          robot_mention_name: robot.mention_name,
          robot_name: robot.name
        )
        response.write(json)
      end

      # A hash of information about Redis.
      def redis_info
        @redis_info ||= redis.info
      end

      # The current version of Redis.
      def redis_version
        redis_info["redis_version"]
      end

      # The amount of memory Redis is using.
      def redis_memory_usage
        redis_info["used_memory_human"]
      end
    end

    Lita.register_handler(Info)
  end
end
