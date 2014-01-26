module Lita
  # A +Rack+ application to serve routes registered by handlers.
  class RackApp
    # The character that separates the pieces of a URL's path component.
    PATH_SEPARATOR = "/"

    # A +Struct+ representing a route's destination handler and method name.
    RouteMapping = Struct.new(:handler, :method_name)

    # All registered paths. Used to respond to HEAD requests.
    # @return [Array<String>] The array of paths.
    attr_reader :all_paths

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

    def call(env)
      request = Rack::Request.new(env)
      mapping = get_mapping(request)
      dispatch(mapping, request)
    end

    # Creates a +Rack+ application from the compiled routes.
    # @return [Rack::Builder] The +Rack+ application.
    def to_app
      app = Rack::Builder.new
      app.run(self)
      app
    end

    private

    # Collect all registered paths. Used for responding to HEAD requests.
    def collect_paths
      @all_paths = routes.values.map { |hash| hash.keys.first }.uniq
    end

    # Registers routes in the route mapping for each handler's defined routes.
    def compile
      Lita.handlers.each do |handler|
        handler.http_routes.each { |route| register_route(handler, route) }
      end
      collect_paths
    end

    # Serve a route or return a 404.
    def dispatch(mapping, request)
      if mapping
        serve(mapping, request)
      elsif request.head? && all_paths.include?(request.path)
        Lita.logger.info "HTTP HEAD #{request.path} was a 204."
        [204, {}, []]
      else
        Lita.logger.info "HTTP #{request.request_method} #{request.path} was a 404."
        [404, {}, ["Route not found."]]
      end
    end

    # Aborts the program if a handler attempts to register a route already registered.
    def ensure_no_duplicate_route(http_method, cleaned_path)
      if @routes[http_method][cleaned_path]
        Lita.logger.fatal <<-ERR.chomp
#{handler.name} attempted to register an HTTP route that was already registered: \
#{http_method} "#{cleaned_path}"
ERR
        abort
      end
    end

    def get_mapping(request)
      routes[request.request_method][request.path]
    end

    # Registers a route.
    def register_route(handler, route)
      cleaned_path = clean_path(route.path)

      ensure_no_duplicate_route(route.http_method, cleaned_path)

      Lita.logger.debug <<-LOG.chomp
Registering HTTP route: #{route.http_method} #{cleaned_path} to \
#{handler}##{route.method_name}.
LOG
      @routes[route.http_method][cleaned_path] = RouteMapping.new(
        handler,
        route.method_name
      )
    end

    def serve(mapping, request)
      Lita.logger.info <<-LOG.chomp
Routing HTTP #{request.request_method} #{request.path} to \
#{mapping.handler}##{mapping.method_name}.
LOG
      response = Rack::Response.new
      instance = mapping.handler.new(robot)
      instance.public_send(mapping.method_name, request, response)
      response.finish
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
