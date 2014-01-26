module Lita
  module RSpec
    module Matchers
      # Used to complete a chat routing test chain.
      class RouteMatcher
        def initialize(context, message_body, invert: false)
          @context = context
          @message_body = message_body
          @method = invert ? :not_to : :to
        end

        # Sets an expectation that a route will or will not be triggered, then
        # sends the message originally provided.
        # @param route [Symbol] The name of the method that should or should not
        #   be triggered.
        # @return [void]
        def to(route)
          m = @method
          b = @message_body

          @context.instance_eval do
            allow(Authorization).to receive(:user_in_group?).and_return(true)
            expect_any_instance_of(described_class).public_send(m, receive(route))
            send_message(b)
          end
        end
      end
    end
  end
end
