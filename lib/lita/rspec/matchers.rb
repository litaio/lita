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

      matcher :route_command do |message_body|
        match do
          message = Message.new(robot, "#{robot.mention_name} #{message_body}", source)

          described_class.routes.any? do |route|
            RouteValidator.new(described_class, route, message, robot).call
          end
        end
      end

      # TODO: Check for route match without calling route.
      matcher :route_http do |http_method, path|
        match do
          http.public_send(http_method, path).success?
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
