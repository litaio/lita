module Lita
  module RSpec
    module Matchers
      # RSpec matchers for chat routes.
      # @since 4.0.0
      module ChatRouteMatcher
        extend ::RSpec::Matchers::DSL

        matcher :route do |message_body|
          match do
            message = Message.new(robot, message_body, source)

            if defined?(@group) and @group.to_s.downcase == "admins"
              robot.config.robot.admins = Array(robot.config.robot.admins) + [source.user.id]
            elsif defined?(@group)
              robot.auth.add_user_to_group!(source.user, @group)
            end

            matching_routes = described_class.routes.select do |route|
              RouteValidator.new(described_class, route, message, robot).call
            end

            if defined?(@method_name)
              matching_routes.any? { |route| route.callback.method_name == @method_name }
            else
              !matching_routes.empty?
            end
          end

          chain :with_authorization_for do |group|
            @group = group
          end

          chain :to do |method_name|
            @method_name = method_name
          end
        end

        # Sets an expectation that the provided message routes to a command.
        # @param message_body [String] The body of the message.
        # @return [void]
        def route_command(message_body)
          route("#{robot.mention_name} #{message_body}")
        end
      end
    end
  end
end
