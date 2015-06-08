module Lita
  # A namespace to hold all subclasses of {Handler}.
  module Handlers
    # Allows administrators to make Lita join and part from rooms.
    # @since 3.0.0
    class Room < Handler

      config :allow_join_from_all_users, required: false, default: false

      route(/^join\s+(.+)$/i, :join, command: true, help: {
        t("help.join_key") => t("help.join_value")
      })

      route(/^part\s+(.+)$/i, :part, command: true, help: {
        t("help.part_key") => t("help.part_value")
      })

      # Joins the room with the specified ID.
      # @param response [Lita::Response] The response object.
      # @return [void]
      def join(response)
        robot.join(response.args[0]) if config.allow_join_from_all_users || robot.auth.user_is_admin?(response.user)
      end

      # Parts from the room with the specified ID.
      # @param response [Lita::Response] The response object.
      # @return [void]
      def part(response)
        robot.part(response.args[0]) if config.allow_join_from_all_users || robot.auth.user_is_admin?(response.user)
      end
    end

    Lita.register_handler(Room)
  end
end
