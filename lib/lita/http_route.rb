module Lita
  class HTTPRoute
    attr_reader :handler_class, :http_method, :path, :method_name

    def initialize(handler_class)
      @handler_class = handler_class
    end

    %i{get post put patch delete options link unlink}.each do |http_method|
      define_method(http_method) do |path, method_name|
        route(http_method.to_s.upcase, path, method_name)
      end
    end

    private

    def route(http_method, path, method_name)
      @http_method = http_method
      @path = path
      @method_name = method_name

      handler_class.http_routes << self
    end
  end
end
