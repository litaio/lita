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

      def route_command(message_body)
        route("#{robot.mention_name} #{message_body}")
      end

      matcher :route_http do |http_method, path|
        match do
          env = Rack::MockRequest.env_for(path, method: http_method)

          matching_routes = robot.app.recognize(env)

          if defined?(@method_name)
            matching_routes.include?(@method_name)
          else
            !matching_routes.empty?
          end
        end

        chain :to do |method_name|
          @method_name = method_name
        end
      end

      matcher :route_event do |event_name|
        match do
          callbacks = described_class.event_subscriptions_for(event_name)

          if defined?(@method_name)
            callbacks.any? { |callback| callback.method_name.equal?(@method_name) }
          else
            !callbacks.empty?
          end
        end

        chain :to do |method_name|
          @method_name = method_name
        end
      end
    end
  end
end
