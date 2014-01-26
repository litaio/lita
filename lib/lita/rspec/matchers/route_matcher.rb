module Lita
  module RSpec
    module Matchers
      # Used to complete a chat routing test chain.
      class RouteMatcher
        attr_accessor :expected_route

        def initialize(context, message_body, invert: false)
          @context = context
          @message_body = message_body
          @method = invert ? :not_to : :to
          @inverted = invert
          set_description
        end

        # Sets an expectation that a route will or will not be triggered, then
        # sends the message originally provided.
        # @param route [Symbol] The name of the method that should or should not
        #   be triggered.
        # @return [void]
        def to(route)
          self.expected_route = route

          m = @method
          b = @message_body

          @context.instance_eval do
            allow(Authorization).to receive(:user_in_group?).and_return(true)
            expect_any_instance_of(described_class).public_send(m, receive(route))
            send_message(b)
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

        def inverted?
          defined?(@inverted) && @inverted
        end

        def set_description
          description = %{#{description_prefix} "#{@message_body}"}
          description << " to :#{expected_route}" if expected_route
          ::RSpec.current_example.metadata[:description] = description
        end
      end
    end
  end
end
