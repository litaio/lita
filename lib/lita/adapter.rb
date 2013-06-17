module Lita
  class Adapter
    attr_reader :robot

    class << self
      attr_reader :required_configs

      def require_config(*keys)
        @required_configs ||= []
        @required_configs.concat(keys.flatten.map(&:to_sym))
      end

      alias_method :require_configs, :require_config
    end

    def initialize(robot)
      @robot = robot
      ensure_required_configs
    end

    private

    def ensure_required_configs
      required_configs = self.class.required_configs
      return if required_configs.nil?

      missing_keys = []

      required_configs.each do |key|
        missing_keys << key unless Lita.config.adapter[key]
      end

      unless missing_keys.empty?
        raise ConfigError.new(
"The following keys are required on config.adapter: #{missing_keys.join(", ")}"
        )
      end
    end
  end
end
