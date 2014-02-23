module Lita
  # A +Rack+ application to serve routes registered by handlers.
  class RackApp
    # The currently running robot.
    # @return [Lita::Robot] The robot.
    attr_reader :robot

    # An +HttpRouter+ used for dispatch.
    # @return [HttpRouter] The router.
    attr_reader :router

    # @param robot [Lita::Robot] The currently running robot.
    def initialize(robot)
      @robot = robot
      @router = HttpRouter.new
      compile
    end

    # Entry point for Lita's HTTP routes. Invokes the Rack application.
    # @param env [Hash] A Rack environment.
    # @return [void]
    def call(env)
      env["lita.robot"] = robot
      router.call(env)
    end

    private

    # Registers routes in the router for each handler's defined routes.
    def compile
      Lita.handlers.each do |handler|
        handler.http_routes.each { |route| router.add_route(route) }
      end
    end
  end
end
