module Lita
  module Handlers
    class Authorization < Handler
      route(/^auth\s+add/, to: :add, command: true)
      route(/^auth\s+remove/, to: :remove, command: true)

      def self.help
        robot_name = Lita.config.robot.name

        {
          "#{robot_name}: auth add USER GROUP" => "Add USER to authorization group GROUP. Requires admin privileges.",
          "#{robot_name}: auth remove USER GROUP" => "Remove USER from authorization group GROUP. Requires admin privileges."
        }
      end

      def add(matches)
        return unless valid_message?

        case Lita::Authorization.add_user_to_group(user, @user, @group)
        when :unauthorized
          reply "Only administrators can add users to groups."
        when true
          reply "#{@user.name} was added to #{@group}."
        else
          reply "#{@user.name} was already in #{@group}."
        end
      end

      def remove(matches)
        return unless valid_message?

        case Lita::Authorization.remove_user_from_group(user, @user, @group)
        when :unauthorized
          reply "Only administrators can remove users from groups."
        when true
          reply "#{@user.name} was removed from #{@group}."
        else
          reply "#{@user.name} was not in #{@group}."
        end
      end

      private

      def valid_message?
        command, identifier, @group = args

        unless identifier && @group
          reply "Format: #{robot.name} auth add USER GROUP"
          return
        end

        @user = User.find_by_id(identifier)
        @user = User.find_by_name(identifier) unless @user

        unless @user
          reply %{No user was found with the identifier "#{identifier}".}
          return
        end

        true
      end
    end

    Lita.register_handler(Authorization)
  end
end
