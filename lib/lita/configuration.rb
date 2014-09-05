module Lita
  class Configuration
    attr_reader :children
    attr_reader :types
    attr_reader :validator

    attr_accessor :name
    attr_accessor :value

    class << self
      def freeze_config(config)
        IceNine.deep_freeze!(config)
      end

      # Loads configuration from a user configuration file.
      # @param config_path [String] The path to the configuration file.
      # @return [void]
      def load_user_config(config_path = nil)
        config_path = "lita_config.rb" unless config_path

        begin
          load(config_path)
        rescue Exception => e
          Lita.logger.fatal I18n.t(
            "lita.config.exception",
            message: e.message,
            backtrace: e.backtrace.join("\n")
          )
          abort
        end if File.exist?(config_path)
      end
    end

    def initialize
      @children = []
      @name = :root
    end

    def combine(name, attribute)
      attribute.name = name

      children << attribute
    end

    def config(name, types: nil, type: nil, default: nil, &block)
      attribute = self.class.new
      attribute.name = name
      attribute.types = types || type
      attribute.value = default
      attribute.instance_exec(&block) if block

      children << attribute
    end

    def finalize(object = Object.new)
      container = if children.empty?
        finalize_simple(object)
      else
        finalize_nested(object)
      end

      container.public_send(name)
    end

    def types=(types)
      @types = Array(types) if types
    end

    def validate(&block)
      @validator = block
    end

    def value=(value)
      if value && types && types.none? { |type| type === value }
        raise TypeError, "#{name} must be one of: #{types.inspect}"
      end

      @value = value
    end

    private

    def finalize_nested(object)
      this = self

      nested_object = Object.new
      children.each { |child| child.finalize(nested_object) }
      object.instance_exec { define_singleton_method(this.name) { nested_object } }

      object
    end

    def finalize_simple(object)
      this = self

      object.instance_exec do
        define_singleton_method(this.name) { this.value }
        define_singleton_method("#{this.name}=") do |value|
          if this.validator
            error = this.validator.call(value)
            raise ValidationError, error if error
          end

          if this.types && this.types.none? { |type| type === value }
            raise TypeError, "#{this.name} must be one of: #{this.types.inspect}"
          end

          this.value = value
        end
      end

      object
    end
  end
end
