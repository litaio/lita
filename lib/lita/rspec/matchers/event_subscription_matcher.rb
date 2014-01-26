module Lita
  module RSpec
    module Matchers
      # Used to complete an event subscription test chain.
      class EventSubscriptionMatcher
        attr_accessor :context, :event_name, :inverted
        attr_reader :expected_route
        alias_method :inverted?, :inverted

        def initialize(context, event_name, invert: false)
          self.context = context
          self.event_name = event_name
          self.inverted = invert
        end

        # Sets an expectation that a handler method will or will not be called in
        # response to a triggered event, then triggers the event.
        # @param target_method_name [String, Symbol] The name of the method that
        #   should or should not be triggered.
        # @return [void]
        def to(target_method_name)
          self.expected_route = target_method_name

          e = event_name
          m = method

          context.instance_eval do
            expect_any_instance_of(described_class).public_send(
              m,
              receive(target_method_name)
            )
            robot.trigger(e)
          end
        end

        private

        def description_prefix
          if inverted?
            "doesn't route event"
          else
            "routes event"
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
          description = %{#{description_prefix} "#{event_name}"}
          description << " to :#{expected_route}" if expected_route
          ::RSpec.current_example.metadata[:description] = description
        end
      end
    end
  end
end
