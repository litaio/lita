module Lita
  # Mixin to add the ability for a plugin to define configuration.
  # @since 4.0.0
  # @api private
  module Configurable
    # The plugins's {Lita::ConfigurationBuilder} object.
    # @return [Lita::ConfigurationBuilder] The configuration builder.
    # @since 4.0.0
    attr_accessor :configuration_builder

    # Sets a configuration attribute on the plugin.
    # @return [void]
    # @since 4.0.0
    # @see Lita::ConfigurationBuilder#config
    def config(*args, **kwargs, &block)
      if block
        configuration_builder.config(*args, **kwargs, &block)
      else
        configuration_builder.config(*args, **kwargs)
      end
    end

    # Initializes the configuration builder for any inheriting classes.
    def inherited(klass)
      super
      klass.configuration_builder = ConfigurationBuilder.new
    end
  end
end
