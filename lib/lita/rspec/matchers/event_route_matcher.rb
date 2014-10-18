module Lita
  module RSpec
    module Matchers
      # RSpec matchers for event routes.
      # @since 4.0.0
      module EventRouteMatcher
        extend ::RSpec::Matchers::DSL

        matcher :route_event do |event_name|
          match do
            callbacks = described_class.event_subscriptions_for(event_name)

            if defined?(@method_name)
              callbacks.any? { |callback| callback.method_name.equal?(@method_name) }
            else
              !callbacks.empty?
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
