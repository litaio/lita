module Lita
  module Handlers
    # Warns about any handlers using deprecated features.
    # @since 4.0.0
    class DeprecationCheck
      extend Lita::Handler::EventRouter

      on :loaded, :check_handlers_for_default_config

      # Warns about handlers using the old +default_config+ method.
      def check_handlers_for_default_config(_payload)
        robot.registry.handlers.each do |handler|
          next unless handler.respond_to?(:default_config)
          Lita.logger.warn(
            I18n.t("lita.config.handler_default_config_deprecated", name: handler.namespace)
          )
        end
      end
    end

    Lita.register_handler(DeprecationCheck)
  end
end
