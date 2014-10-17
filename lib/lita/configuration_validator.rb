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
      adapters.each_value do |adapter|
        adapter.configuration.children.each do |attribute|
          if attribute.required? && attribute.value.nil?
            raise ValidationError, I18n.t(
              "lita.config.missing_required_adapter_attribute",
              adapter: adapter.namespace,
              attribute: attribute.name
            )
          end
        end
      end
    end

    def validate_handlers
      handlers.each do |handler|
        handler.configuration.children.each do |attribute|
          if attribute.required? && attribute.value.nil?
            raise ValidationError, I18n.t(
              "lita.config.missing_required_handler_attribute",
              handler: handler.namespace,
              attribute: attribute.name
            )
          end
        end
      end
    end
  end
end
