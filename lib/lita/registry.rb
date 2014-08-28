module Lita
  class Registry
    module Mixins
      # The global configuration object. Provides user settings for the robot.
      # @return [Lita::Config] The Lita configuration object.
      def config
        @config ||= DefaultConfiguration.new(self).finalize
      end

      # Yields the global configuration object. Called by the user in a
      # lita_config.rb file.
      # @yieldparam [Lita::Configuration] config The global configuration object.
      # @return [void]
      def configure
        yield config
      end

      # The global registry of adapters.
      # @return [Hash] A map of adapter keys to adapter classes.
      def adapters
        @adapters ||= {}
      end

      # The global registry of handlers.
      # @return [Set] The set of handlers.
      def handlers
        @handlers ||= Set.new
      end

      # The global registry of hook handler objects.
      # @return [Hash] A hash mapping hook names to sets of objects that handle them.
      # @since 3.2.0
      def hooks
        @hooks ||= Hash.new { |h, k| h[k] = Set.new }
      end

      # Adds an adapter to the global registry under the provided key.
      # @param key [String, Symbol] The key that identifies the adapter.
      # @param adapter [Lita::Adapter] The adapter class.
      # @return [void]
      def register_adapter(key, adapter = nil, &block)
        adapter = Builder.new(key, &block).build_adapter if block

        adapters[key.to_sym] = adapter
      end

      # Adds a handler to the global registry.
      # @param handler [Lita::Handler] The handler class.
      # @return [void]
      def register_handler(handler_or_key, &block)
        if block
          handler = Builder.new(handler_or_key, &block).build_handler
        else
          handler = handler_or_key

          unless handler.is_a?(Class)
            raise ArgumentError, I18n.t("lita.core.register_handler.block_or_class_required")
          end
        end

        handlers << handler
      end

      # Adds a hook handler object to the global registry for the given hook.
      # @return [void]
      # @since 3.2.0
      def register_hook(name, hook)
        hooks[name.to_s.downcase.strip.to_sym] << hook
      end

      # Clears the global configuration object and the global adapter, handler, and hook registries.
      # @return [void]
      # @since 3.2.0
      def reset
        reset_adapters
        reset_config
        reset_handlers
        reset_hooks
      end

      # Resets the global adapter registry, removing all registered adapters.
      # @return [void]
      # @since 3.2.0
      def reset_adapters
        @adapters = nil
      end

      # Resets the global configuration object. The next call to {Lita.config}
      # will create a fresh config object.
      # @return [void]
      def reset_config
        @config = nil
      end
      alias_method :clear_config, :reset_config

      # Resets the global handler registry, removing all registered handlers.
      # @return [void]
      # @since 3.2.0
      def reset_handlers
        @handlers = nil
      end

      # Resets the global hooks registry, removing all registered hook handlers.
      # @return [void]
      # @since 3.2.0
      def reset_hooks
        @hooks = nil
      end
    end

    include Mixins
  end
end
