module Lita
  module RSpec
    module Matchers
      # Used to complete an HTTP routing test chain.
      class HTTPRouteMatcher
        def initialize(context, http_method, path, invert: false)
          @context = context
          @http_method = http_method
          @path = path
          @method = invert ? :not_to : :to
        end

        # Sets an expectation that an HTTP route will or will not be triggered,
        #   then makes an HTTP request against the app with the HTTP request
        #   method and path originally provided.
        # @param route [Symbol] The name of the method that should or should not
        #   be triggered.
        # @return [void]
        def to(route)
          m = @method
          h = @http_method
          p = @path

          @context.instance_eval do
            expect_any_instance_of(described_class).public_send(m, receive(route))
            env = Rack::MockRequest.env_for(p, method: h)
            robot.app.call(env)
          end
        end
      end
    end
  end
end
