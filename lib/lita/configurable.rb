module Lita
  # Mixin to add the ability for a plugin to define configuration.
  # @since 4.0.0
  # @api private
  module Configurable
    # The plugins's {Configuration} object.
    # @return [Lita::Configuration] The configuration object.
    # @since 4.0.0
    attr_accessor :configuration

    # Sets a configuration attribute on the plugin.
    # @return [void]
    # @since 4.0.0
    # @see Lita::Configuration#config
    def config(*args, **kwargs)
      if block_given?
        configuration.config(*args, **kwargs, &proc)
      else
        configuration.config(*args, **kwargs)
      end
    end

    # Initializes the configuration object for any inheriting classes.
    def inherited(klass)
      super
      klass.configuration = Configuration.new
    end
  end
end
