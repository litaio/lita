module Lita
  module RSpec
    module Matchers
      # Used to complete an HTTP routing test chain.
      class HTTPRouteMatcher
        attr_accessor :context, :http_method, :inverted, :path
        attr_reader :expected_route
        alias_method :inverted?, :inverted

        def initialize(context, http_method, path, invert: false)
          self.context = context
          self.http_method = http_method
          self.path = path
          self.inverted = invert
          set_description
        end

        # Sets an expectation that an HTTP route will or will not be triggered,
        #   then makes an HTTP request against the app with the HTTP request
        #   method and path originally provided.
        # @param route [Symbol] The name of the method that should or should not
        #   be triggered.
        # @return [void]
        def to(route)
          self.expected_route = route

          m = method
          h = http_method
          p = path

          context.instance_eval do
            expect_any_instance_of(described_class).public_send(m, receive(route))
            env = Rack::MockRequest.env_for(p, method: h)
            robot.app.call(env)
          end
        end

        private

        def description_prefix
          if inverted?
            "doesn't route"
          else
            "routes"
          end
        end

        def expected_route=(route)
          @expected_route = route
          set_description
        end

        def method
          if inverted?
            :not_to
          else
            :to
          end
        end

        def set_description
          description = "#{description_prefix} #{http_method.upcase} #{path}"
          description << " to :#{expected_route}" if expected_route
          ::RSpec.current_example.metadata[:description] = description
        end
      end
    end
  end
end
