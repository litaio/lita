module Lita
  module RSpec
    # A namespace to hold all of Lita's RSpec matchers.
    module Matchers
      # RSpec matchers for HTTP routes.
      # @since 4.0.0
      module HTTPRouteMatcher
        extend ::RSpec::Matchers::DSL

        matcher :route_http do |http_method, path|
          match do
            env = Rack::MockRequest.env_for(path, method: http_method)

            matching_routes = robot.app.recognize(env)

            if defined?(@method_name)
              matching_routes.include?(@method_name)
            else
              !matching_routes.empty?
            end
          end

          chain :to do |method_name|
            @method_name = method_name
          end
        end
      end
    end
  end
end
