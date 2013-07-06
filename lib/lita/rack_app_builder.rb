module Lita
  # Creates a +Rack+ application from all the routes registered by handlers.
  class RackAppBuilder
    # The character that separates the pieces of a URL's path component.
    PATH_SEPARATOR = "/"

    # A +Struct+ representing a route's destination handler and method name.
    RouteMapping = Struct.new(:handler, :method_name)

    # The currently running robot.
    # @return [Lita::Robot] The robot.
    attr_reader :robot

    # A hash mapping HTTP request methods and paths to handlers and methods.
    # @return [Hash] The mapping.
    attr_reader :routes

    # @param robot [Lita::Robot] The currently running robot.
    def initialize(robot)
      @robot = robot
      @routes = Hash.new { |h, k| h[k] = {} }
      compile
    end

    # Creates a +Rack+ application from the compiled routes.
    # @return [Rack::Builder] The +Rack+ application.
    def to_app
      app = Rack::Builder.new
      app.run(app_proc)
      app
    end

    private

    # The proc that serves as the +Rack+ application.
    def app_proc
      -> (env) do
        request = Rack::Request.new(env)

        mapping = routes[request.request_method][request.path]

        if mapping
          Lita.logger.info <<-LOG.chomp
Routing HTTP #{request.request_method} #{request.path} to \
#{mapping.handler}##{mapping.method_name}.
LOG
          response = Rack::Response.new
          instance = mapping.handler.new(robot)
          instance.public_send(mapping.method_name, request, response)
          response.finish
        else
          Lita.logger.info <<-LOG.chomp
HTTP #{request.request_method} #{request.path} was a 404.
LOG
          [404, {}, "Route not found."]
        end
      end
    end

    # Registers routes in the route mapping for each handler's defined routes.
    def compile
      Lita.handlers.each do |handler|
        handler.http_routes.each { |route| register_route(handler, route) }
      end
    end

    # Registers a route.
    def register_route(handler, route)
      cleaned_path = clean_path(route.path)

      if @routes[route.http_method][cleaned_path]
        Lita.logger.fatal <<-ERR.chomp
#{handler.name} attempted to register an HTTP route that was already \
registered: #{route.http_method} "#{cleaned_path}"
ERR
        abort
      end

      Lita.logger.debug <<-LOG.chomp
Registering HTTP route: #{route.http_method} #{cleaned_path} to \
#{handler}##{route.method_name}.
LOG
      @routes[route.http_method][cleaned_path] = RouteMapping.new(
        handler,
        route.method_name
      )
    end

    # Ensures that paths begin with one slash and do not end with one.
    def clean_path(path)
      path.strip!
      path.chop! while path.end_with?(PATH_SEPARATOR)
      path = path[1..-1] while path.start_with?(PATH_SEPARATOR)
      "/#{path}"
    end
  end
end
