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

    def handlers
      @registry.handlers
    end

    def validate_adapters
      adapters.each_value { |adapter| validate(:adapter, adapter) }
    end

    def validate_handlers
      handlers.each { |handler| validate(:handler, handler) }
    end

    def validate(type, plugin)
      plugin.configuration.children.each do |attribute|
        if attribute.required? && attribute.value.nil?
          raise ValidationError, I18n.t(
            "lita.config.missing_required_#{type}_attribute",
            type => plugin.namespace,
            attribute: attribute.name
          )
        end
      end
    end
  end
end
