module Lita
  module RSpec
    # A namespace to hold all of Lita's RSpec matchers.
    module Matchers
      # Used to complete an event subscription test chain.
      class EventSubscriptionMatcher
        attr_accessor :context, :event_name, :expectation
        attr_reader :expected_route

        def initialize(context, event_name, expectation: true)
          self.context = context
          self.event_name = event_name
          self.expectation = expectation
        end

        # Sets an expectation that a handler method will or will not be called in
        # response to a triggered event, then triggers the event.
        # @param target_method_name [String, Symbol] The name of the method that
        #   should or should not be triggered.
        # @return [void]
        def to(target_method_name)
          self.expected_route = target_method_name

          e = expectation
          ev = event_name
          i = i18n_key

          context.instance_eval do
            called = false
            allow(subject).to receive(target_method_name) { called = true }
            robot.trigger(ev)
            expect(called).to be(e), I18n.t(i, event: ev, route: target_method_name)
          end
        end

        private

        def description_prefix
          if expectation
            "routes event"
          else
            "doesn't route event"
          end
        end

        def expected_route=(route)
          @expected_route = route
          set_description
        end

        def i18n_key
          if expectation
            "lita.rspec.event_subscription_failure"
          else
            "lita.rspec.negative_event_subscription_failure"
          end
        end

        def set_description
          description = %(#{description_prefix} "#{event_name}")
          description << " to :#{expected_route}" if expected_route
          ::RSpec.current_example.metadata[:description] = description
        end
      end
    end
  end
end
