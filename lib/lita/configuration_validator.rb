module Lita
  class ConfigurationValidator
    def initialize(registry)
      @registry = registry
    end

    def call
      validate_adapters
      validate_handlers
    end

    private

    def adapters
      @registry.adapters
    end

    def children_for(plugin)
      plugin.configuration.children
    end

    def full_attribute_name(names, name)
      (names + [name]).join(".")
    end

    def handlers
      @registry.handlers
    end

    def validate_adapters
      adapters.each_value { |adapter| validate(:adapter, adapter, children_for(adapter)) }
    end

    def validate_handlers
      handlers.each { |handler| validate(:handler, handler, children_for(handler)) }
    end

    def validate(type, plugin, attributes, attribute_namespace = [])
      attributes.each do |attribute|
        if attribute.children?
          validate(type, plugin, attribute.children, attribute_namespace.clone.push(attribute.name))
        elsif attribute.required? && attribute.value.nil?
          raise ValidationError, I18n.t(
            "lita.config.missing_required_#{type}_attribute",
            type => plugin.namespace,
            attribute: full_attribute_name(attribute_namespace, attribute.name)
          )
        end
      end
    end
  end
end
