module Lita
  class RackAppBuilder
    PATH_SEPARATOR = "/"

    RouteMapping = Struct.new(:handler, :method_name)

    attr_reader :robot, :routes

    def initialize(robot)
      @robot = robot
      @routes = Hash.new { |h, k| h[k] = {} }
      compile
    end

    def to_app
      app = Rack::Builder.new
      app.run(app_proc)
      app
    end

    private

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

    def compile
      Lita.handlers.each do |handler|
        handler.http_routes.each { |route| register_route(handler, route) }
      end
    end

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

    def clean_path(path)
      path.strip!
      path.chop! while path.end_with?(PATH_SEPARATOR)
      path = path[1..-1] while path.start_with?(PATH_SEPARATOR)
      "/#{path}"
    end
  end
end
