module Lita
  # A +Rack+ application to serve routes registered by handlers.
  class RackApp
    # The currently running robot.
    # @return [Lita::Robot] The robot.
    attr_reader :robot

    # An +HttpRouter+ used for dispatch.
    # @return [HttpRouter] The router.
    attr_reader :router

    def self.build(robot)
      builder = Rack::Builder.new
      builder.run(new(robot))
      robot.config.http.middleware.each { |middleware| builder.use(middleware) }
      builder.to_app
    end

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

    def recognize(env)
      env["lita.robot"] = robot
      recognized_routes_for(env).map { |match| match.route.name }
    end

    private

    # Registers routes in the router for each handler's defined routes.
    def compile
      robot.handlers.each do |handler|
        next unless handler.respond_to?(:http_routes)

        handler.http_routes.each { |route| router.add_route(route) }
      end
    end

    def recognized_routes_for(env)
      Array(router.recognize(env).first)
    end
  end
end
