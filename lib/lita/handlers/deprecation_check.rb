module Lita
  module Handlers
    class DeprecationCheck
      extend Lita::Handler::EventRouter

      on :loaded, :check_handlers_for_default_config

      def check_handlers_for_default_config(_payload)
        robot.registry.handlers.each do |handler|
          if handler.respond_to?(:default_config)
            Lita.logger.warn(
              I18n.t("lita.config.handler_default_config_deprecated", name: handler.namespace)
            )
          end
        end
      end
    end

    Lita.register_handler(DeprecationCheck)
  end
end
