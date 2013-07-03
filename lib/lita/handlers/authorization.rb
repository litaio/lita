module Lita
  module Handlers
    class Authorization < Handler
      route(/^auth\s+add/, to: :add, command: true, help: {
        "auth add USER GROUP" => "Add USER to authorization group GROUP. Requires admin privileges."
      })
      route(/^auth\s+remove/, to: :remove, command: true, help: {
        "auth remove USER GROUP" => "Remove USER from authorization group GROUP. Requires admin privileges."
      })

      def add(response)
        return unless valid_message?(response)

        case Lita::Authorization.add_user_to_group(response.user, @user, @group)
        when :unauthorized
          response.reply "Only administrators can add users to groups."
        when true
          response.reply "#{@user.name} was added to #{@group}."
        else
          response.reply "#{@user.name} was already in #{@group}."
        end
      end

      def remove(response)
        return unless valid_message?(response)

        case Lita::Authorization.remove_user_from_group(
          response.user,
          @user,
          @group
        )
        when :unauthorized
          response.reply "Only administrators can remove users from groups."
        when true
          response.reply "#{@user.name} was removed from #{@group}."
        else
          response.reply "#{@user.name} was not in #{@group}."
        end
      end

      private

      def valid_message?(response)
        command, identifier, @group = response.args

        unless identifier && @group
          response.reply "Format: #{robot.name} auth add USER GROUP"
          return
        end

        @user = User.find_by_id(identifier)
        @user = User.find_by_name(identifier) unless @user

        unless @user
          response.reply <<-REPLY.chomp
No user was found with the identifier "#{identifier}".
REPLY
          return
        end

        true
      end
    end

    Lita.register_handler(Authorization)
  end
end
