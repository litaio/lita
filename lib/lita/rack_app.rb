module Lita
  # A +Rack+ application to serve HTTP routes registered by handlers.
  class RackApp
    # The currently running robot.
    # @return [Lita::Robot] The robot.
    attr_reader :robot

    # An +HttpRouter+ used for dispatch.
    # @return [HttpRouter] The router.
    attr_reader :router

    # Constructs a {RackApp} inside a +Rack::Builder+, including any configured middleware.
    # @param robot [Lita::Robot] The currently running robot.
    # @return [Lita::RackApp, Class] The Rack application.
    def self.build(robot)
      builder = Rack::Builder.new
      builder.run(new(robot))

      robot.config.http.middleware.each do |wrapper|
        if wrapper.block
          builder.use(wrapper.middleware, *wrapper.args, &wrapper.block)
        else
          builder.use(wrapper.middleware, *wrapper.args)
        end
      end

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

    # Finds the first route that matches the request environment, if any. Does not trigger the
    # route.
    # @param env [Hash] A Rack environment.
    # @return [Array] An array of the name of the first matching route.
    # @since 4.0.0
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

    # Returns an array containing the first recongnized route, if any.
    def recognized_routes_for(env)
      Array(router.recognize(env).first)
    end
  end
end
