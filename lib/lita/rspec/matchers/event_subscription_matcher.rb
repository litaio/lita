module Lita
  module RSpec
    module Matchers
      # Used to complete an event subscription test chain.
      class EventSubscriptionMatcher
        def initialize(context, event_name, invert: false)
          @context = context
          @event_name = event_name
          @method = invert ? :not_to : :to
        end

        # Sets an expectation that a handler method will or will not be called in
        # response to a triggered event, then triggers the event.
        # @param target_method_name [String, Symbol] The name of the method that
        #   should or should not be triggered.
        # @return [void]
        def to(target_method_name)
          e = @event_name
          m = @method

          @context.instance_eval do
            expect_any_instance_of(described_class).public_send(
              m,
              receive(target_method_name)
            )
            robot.trigger(e)
          end
        end
      end
    end
  end
end
