module Lita
  class Handler
    module EventRouter
      def self.extended(klass)
        klass.send(:include, Common)
      end

      # Registers an event subscription. When an event is triggered with
      # {trigger}, a new instance of the handler will be created and the
      # instance method name supplied to {on} will be invoked with a payload
      # (a hash of arbitrary keys and values).
      # @param event_name [String, Symbol] The name of the event to subscribe
      #   to.
      # @param method_name [String, Symbol] The name of the instance method on
      #   the handler that should be invoked when the event is triggered.
      # @return [void]
      def on(event_name, method_name_or_callable = nil, &block)
        event_subscriptions[normalize_event(event_name)] << EventCallback.new(
          method_name_or_callable || block
        )
      end

      # Triggers an event, invoking methods previously registered with {on} and
      # passing them a payload hash with any arbitrary data.
      # @param robot [Lita::Robot] The currently running robot instance.
      # @param event_name [String, Symbol], The name of the event to trigger.
      # @param payload [Hash] An optional hash of arbitrary data.
      # @return [Boolean] Whether or not the event triggered any callbacks.
      def trigger(robot, event_name, payload = {})
        event_subscriptions[normalize_event(event_name)].any? do |callback|
          callback.call(new(robot), payload)
        end
      end

      private

      # A hash of arrays used to store event subscriptions registered with {on}.
      def event_subscriptions
        @event_subscriptions ||= Hash.new { |h, k| h[k] = [] }
      end

      def normalize_event(event_name)
        event_name.to_s.downcase.strip.to_sym
      end
    end
  end
end
