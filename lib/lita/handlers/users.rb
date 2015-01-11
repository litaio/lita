module Lita
  module Handlers
    # Provides information on Lita users.
    # @since 4.1.0
    class Users
      extend Lita::Handler::ChatRouter

      route(/^users\s+find\s+(.+)/i, :find, command: true, help: {
        t("help.find_key") => t("help.find_value")
      })

      # Outputs the name, ID, and mention name of a user matching the search query.
      # @param response [Lita::Response] The response object.
      # @return [void]
      def find(response)
        user = Lita::User.fuzzy_find(response.args[1])

        if user
          response.reply(formatted_user(user))
        else
          response.reply(t("find_empty_state"))
        end
      end

      private

      # Extract and label the relevant user information.
      def formatted_user(user)
        "#{user.name} (ID: #{user.id}, Mention name: #{user.mention_name})"
      end
    end

    Lita.register_handler(Users)
  end
end
