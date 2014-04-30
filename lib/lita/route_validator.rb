module Lita
  # Determines if an incoming message should trigger a route.
  # @api private
  class RouteValidator
    # The incoming message.
    attr_reader :message

    # The currently running robot.
    attr_reader :robot

    # The route being checked.
    attr_reader :route

    def initialize(route, message, robot)
      @route = route
      @message = message
      @robot = robot
    end

    # Returns a boolean indicating whether or not the route should be triggered.
    # @return [Boolean] Whether or not the route should be triggered.
    def call
      return unless passes_route_hooks?(route, message, robot)
      return unless command_satisfied?(route, message)
      return if from_self?(message, robot)
      return unless matches_pattern?(route, message)
      return unless authorized?(message.user, route.required_groups)

      true
    end

    private

    # Message must be a command if the route requires a command
    def command_satisfied?(route, message)
      !route.command? || message.command?
    end

    # Messages from self should be ignored to prevent infinite loops
    def from_self?(message, robot)
      message.user.name == robot.name
    end

    # Message must match the pattern
    def matches_pattern?(route, message)
      route.pattern === message.body
    end

    # Allow custom route hooks to reject the route
    def passes_route_hooks?(route, message, robot)
      Lita.hooks[:validate_route].all? do |hook|
        hook.call(route: route, message: message, robot: robot)
      end
    end

    # User must be in auth group if route is restricted.
    def authorized?(user, required_groups)
      required_groups.nil? || required_groups.any? do |group|
        Authorization.user_in_group?(user, group)
      end
    end
  end
end
