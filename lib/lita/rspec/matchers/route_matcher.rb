module Lita
  module RSpec
    module Matchers
      # Used to complete a chat routing test chain.
      class RouteMatcher
        attr_accessor :context, :expectation, :message_body
        attr_reader :expected_route

        def initialize(context, message_body, expectation: true)
          self.context = context
          self.message_body = message_body
          self.expectation = expectation
          set_description
        end

        # Sets an expectation that a route will or will not be triggered, then
        # sends the message originally provided.
        # @param route [Symbol] The name of the method that should or should not
        #   be triggered.
        # @return [void]
        def to(route)
          self.expected_route = route

          e = expectation
          b = message_body
          i = i18n_key

          context.instance_eval do
            allow(Authorization).to receive(:user_in_group?).and_return(true)
            called = false
            allow(subject).to receive(route) { called = true }
            send_message(b)
            expect(called).to be(e), I18n.t(i, message: b, route: route)
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
            "lita.rspec.route_failure"
          else
            "lita.rspec.negative_route_failure"
          end
        end

        def set_description
          description = %{#{description_prefix} "#{message_body}"}
          description << " to :#{expected_route}" if expected_route
          ::RSpec.current_example.metadata[:description] = description
        end
      end
    end
  end
end
