# frozen_string_literal: true

module Lita
  # Validates a registry's configuration, checking for required attributes that are missing.
  # @since 4.0.0
  # @api private
  class ConfigurationValidator
    # @param registry [Registry] The registry containing the configuration to validate.
    def initialize(registry)
      self.registry = registry
    end

    # Validates adapter and handler configuration. Logs a fatal warning and aborts if any required
    # configuration attributes are missing.
    # @return [void]
    def call
      validate_adapters
      validate_handlers
    end

    private

    # The registry containing the configuration to validate.
    attr_accessor :registry

    # The registry's adapters.
    def adapters
      registry.adapters
    end

    # All a plugin's top-level configuration attributes.
    def children_for(plugin)
      plugin.configuration_builder.children
    end

    # Return the {Configuration} for the given plugin.
    # @param type [String, Symbol] Either "adapters" or "handlers".
    # @param name [String, Symbol] The name of the plugin's top-level {Configuration}.
    # @param namespace [Array<String, Symbol>] A list of nested config attributes to traverse to
    #   find the desired {Configuration}.
    def config_for(type, name, namespace)
      config = registry.config.public_send(type).public_send(name)
      namespace.each { |n| config = config.public_send(n) }
      config
    end

    # Generates the fully qualified name of a configuration attribute.
    def full_attribute_name(names, name)
      (names + [name]).join(".")
    end

    # The registry's handlers.
    def handlers
      registry.handlers
    end

    # Validates the registry's adapters.
    def validate_adapters
      adapters.each do |adapter_name, adapter|
        validate(:adapter, adapter_name, adapter, children_for(adapter))
      end
    end

    # Validates the registry's handlers.
    def validate_handlers
      handlers.each do |handler|
        validate(:handler, handler.namespace, handler, children_for(handler))
      end
    end

    # Validates an array of attributes, recursing if any nested attributes are encountered.
    def validate(type, plugin_name, plugin, attributes, attribute_namespace = [])
      attributes.each do |attribute|
        config = config_for("#{type}s", plugin_name, attribute_namespace)

        if attribute.children?
          validate(
            type,
            plugin_name,
            plugin,
            attribute.children,
            attribute_namespace.clone.push(attribute.name),
          )
        elsif attribute.required? && config.public_send(attribute.name).nil?
          Lita.logger.fatal I18n.t(
            "lita.config.missing_required_#{type}_attribute",
            type => plugin_name,
            attribute: full_attribute_name(attribute_namespace, attribute.name)
          )
          exit(false)
        end
      end
    end
  end
end
