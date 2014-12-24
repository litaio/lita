module Lita
  class Handler
    # A handler mixin that provides the methods necessary for handling events.
    # @since 4.0.0
    module EventRouter
      # Includes common handler methods in any class that includes {EventRouter}.
      def self.extended(klass)
        klass.send(:include, Common)
      end

      # @overload on(event_name, method_name)
      #   Registers an event subscription. When an event is triggered with
      #   {#trigger}, a new instance of the handler will be created and the
      #   instance method name supplied to {#on} will be invoked with a payload
      #   (a hash of arbitrary keys and values).
      #   @param event_name [String, Symbol] The name of the event to subscribe to.
      #   @param method_name [String, Symbol] The name of the instance method on
      #     the handler that should be invoked when the event is triggered.
      #   @return [void]
      # @overload on(event_name, callable)
      #   Registers an event subscription. When an event is triggered with
      #   {#trigger}, a new instance of the handler will be created and the
      #   callable object supplied to {#on} will be evaluated within the context of the new
      #   handler instance, and passed a payload (a hash of arbitrary keys and values).
      #   @param event_name [String, Symbol] The name of the event to subscribe to.
      #   @param callable [#call] A callable object to serve as the event callback.
      #   @return [void]
      #   @since 4.0.0
      # @overload on(event_name)
      #   Registers an event subscription. When an event is triggered with
      #   {#trigger}, a new instance of the handler will be created and the
      #   block supplied to {#on} will be evaluated within the context of the new
      #   handler instance, and passed a payload (a hash of arbitrary keys and values).
      #   @param event_name [String, Symbol] The name of the event to subscribe to.
      #   @yield The body of the event callback.
      #   @return [void]
      #   @since 4.0.0
      def on(event_name, method_name_or_callable = nil, &block)
        event_subscriptions[normalize_event(event_name)] << Callback.new(
          method_name_or_callable || block
        )
      end

      # Returns an array of all callbacks registered for the named event.
      # @param event_name [String, Symbol] The name of the event to return callbacks for.
      # @return [Array] The array of callbacks.
      # @since 4.0.0
      def event_subscriptions_for(event_name)
        event_subscriptions[normalize_event(event_name)]
      end

      # Triggers an event, invoking methods previously registered with {#on} and
      # passing them a payload hash with any arbitrary data.
      # @param robot [Lita::Robot] The currently running robot instance.
      # @param event_name [String, Symbol], The name of the event to trigger.
      # @param payload [Hash] An optional hash of arbitrary data.
      # @return [Boolean] Whether or not the event triggered any callbacks.
      def trigger(robot, event_name, payload = {})
        event_subscriptions_for(event_name).map do |callback|
          callback.call(new(robot), payload)
        end.any?
      end

      private

      # A hash of arrays used to store event subscriptions registered with {#on}.
      def event_subscriptions
        @event_subscriptions ||= Hash.new { |h, k| h[k] = [] }
      end

      # Normalize the event name, ignoring casing and spaces.
      def normalize_event(event_name)
        event_name.to_s.downcase.strip.to_sym
      end
    end
  end
end
