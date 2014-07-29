module Lita
  module RSpec
    module Matchers
      extend ::RSpec::Matchers::DSL

      matcher :route do |message_body|
        match do
          message = Message.new(robot, message_body, source)

          described_class.routes.any? do |route|
            RouteValidator.new(described_class, route, message, robot).call
          end
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

      # TODO: Check for route match without calling route.
      matcher :route_event do |event_name|
        match do
          described_class.trigger(robot, event_name, {})
        end
      end
    end
  end
end
