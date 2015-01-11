module Lita
  # A namespace to hold all subclasses of {Handler}.
  module Handlers
    # Provides a chat interface for administering authorization groups.
    class Authorization < Handler
      route(
        /^auth\s+add/,
        :add,
        command: true,
        restrict_to: :admins,
        help: { t("help.add_key") => t("help.add_value") }
      )
      route(
        /^auth\s+remove/,
        :remove,
        command: true,
        restrict_to: :admins,
        help: { t("help.remove_key") => t("help.remove_value") }
      )
      route(/^auth\s+list/, :list, command: true, restrict_to: :admins, help: {
        t("help.list_key") => t("help.list_value")
      })

      # Adds a user to an authorization group.
      # @param response [Lita::Response] The response object.
      # @return [void]
      def add(response)
        toggle_membership(response, :add_user_to_group, "user_added", "user_already_in")
      end

      # Removes a user from an authorization group.
      # @param response [Lita::Response] The response object.
      # @return [void]
      def remove(response)
        toggle_membership(response, :remove_user_from_group, "user_removed", "user_not_in")
      end

      # Lists all authorization groups (or only the specified group) and the
      # names of their members.
      # @param response [Lita::Response] The response object.
      # @return [void]
      def list(response)
        requested_group = response.args[1]
        output = get_groups_list(response.args[1])
        if output.empty?
          response.reply(empty_state_for_list(requested_group))
        else
          response.reply(output.join("\n"))
        end
      end

      private

      def empty_state_for_list(requested_group)
        if requested_group
          t("empty_state_group", group: requested_group)
        else
          t("empty_state")
        end
      end

      def get_groups_list(requested_group)
        groups_with_users = robot.auth.groups_with_users
        if requested_group
          requested_group = requested_group.downcase.strip.to_sym
          groups_with_users.select! { |group, _| group == requested_group }
        end
        groups_with_users.map do |group, users|
          user_names = users.map(&:name).join(", ")
          "#{group}: #{user_names}"
        end
      end

      def toggle_membership(response, method_name, success_key, failure_key)
        return unless valid_message?(response)

        if robot.auth.public_send(method_name, response.user, @user, @group)
          response.reply t(success_key, user: @user.name, group: @group)
        else
          response.reply t(failure_key, user: @user.name, group: @group)
        end
      end

      def valid_group?(response, identifier)
        unless identifier && @group
          response.reply "#{t('format')}: #{robot.name} auth add USER GROUP"
          return
        end

        if @group.downcase.strip == "admins"
          response.reply t("admin_management")
          return
        end

        true
      end

      # Validates that incoming messages have the right format and a valid user.
      # Also assigns the user and group to instance variables for the main
      # methods to use later.
      def valid_message?(response)
        _command, identifier, @group = response.args

        return unless valid_group?(response, identifier)

        return unless valid_user?(response, identifier)

        true
      end

      def valid_user?(response, identifier)
        @user = User.fuzzy_find(identifier)

        if @user
          true
        else
          response.reply t("no_user_found", identifier: identifier)
          return
        end
      end
    end

    Lita.register_handler(Authorization)
  end
end
