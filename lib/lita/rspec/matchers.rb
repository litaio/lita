module Lita
  module RSpec
    module Matchers
      extend ::RSpec::Matchers::DSL

      matcher :route do |message_body|
        match do
          message = Message.new(robot, message_body, source)

          if defined?(@group) and @group.to_s.downcase == "admins"
            robot.config.robot.admins = Array(robot.config.robot.admins) + [source.user.id]
          elsif defined?(@group)
            robot.auth.add_user_to_group!(source.user, @group)
          end

          described_class.routes.any? do |route|
            RouteValidator.new(described_class, route, message, robot).call
          end
        end

        chain :with_authorization_for do |group|
          @group = group
        end
      end

      def route_command(message_body)
        route("#{robot.mention_name} #{message_body}")
      end

      matcher :route_http do |http_method, path|
        match do
          env = Rack::MockRequest.env_for(path, method: http_method)
          robot.app.recognize(env)
        end
      end

      matcher :route_event do |event_name|
        match do
          described_class.event_subscriptions_for(event_name).any?
        end
      end
    end
  end
end
