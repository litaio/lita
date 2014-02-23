module Lita
  module RSpec
    # A namespace to hold all of Lita's RSpec matchers.
    module Matchers
      # Used to complete an HTTP routing test chain.
      class HTTPRouteMatcher
        attr_accessor :context, :http_method, :expectation, :path
        attr_reader :expected_route

        def initialize(context, http_method, path, expectation: true)
          self.context = context
          self.http_method = http_method
          self.path = path
          self.expectation = expectation
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

          e = expectation
          m = http_method.upcase
          p = path
          i = i18n_key

          context.instance_eval do
            called = false
            allow(subject).to receive(route) { called = true }
            env = Rack::MockRequest.env_for(p, method: m)
            robot.app.call(env)
            expect(called).to be(e), I18n.t(i, method: m, path: p, route: route)
          end
        end

        private

        def description_prefix
          if expectation
            "routes"
          else
            "doesn't route"
          end
        end

        def expected_route=(route)
          @expected_route = route
          set_description
        end

        def i18n_key
          if expectation
            "lita.rspec.http_route_failure"
          else
            "lita.rspec.negative_http_route_failure"
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
