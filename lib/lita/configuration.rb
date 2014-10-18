module Lita
  # An object that stores various settings that affect Lita's behavior.
  # @since 4.0.0
  class Configuration
    # An array of any nested configuration objects.
    # @return [Array<Lita::Configuration>] The array of child configuration objects.
    attr_reader :children

    # An array of valid types for the attribute.
    # @return [Array<Object>] The array of valid types.
    attr_reader :types

    # A block used to validate the attribute.
    # @return [Proc] The validation block.
    attr_reader :validator

    # The name of the configuration attribute.
    # @return [String, Symbol] The attribute's name.
    attr_accessor :name

    # The value of the configuration attribute.
    # @return [Object] The attribute's value.
    attr_accessor :value

    # A boolean indicating whether or not the attribute must be set.
    # @return [Boolean] Whether or not the attribute is required.
    attr_accessor :required
    alias_method :required?, :required

    class << self
      # Deeply freezes a configuration object so that it can no longer be modified.
      # @param config [Lita::Configuration] The configuration object to freeze.
      # @return [void]
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

    # Returns a boolean indicating whether or not the attribute has any child attributes.
    # @return [Boolean] Whether or not the attribute has any child attributes.
    def children?
      !children.empty?
    end

    # Merges two configuration objects by making one an attribute on the other.
    # @param name [String, Symbol] The name of the new attribute.
    # @param attribute [Lita::Configuration] The configuration object that should be its value.
    # @return [void]
    def combine(name, attribute)
      attribute.name = name

      children << attribute
    end

    # Declares a configuration attribute.
    # @param name [String, Symbol] The attribute's name.
    # @param types [Object, Array<Object>] Optional: One or more types that the attribute's value
    #   must be.
    # @param type [Object, Array<Object>] Optional: One or more types that the attribute's value
    #   must be.
    # @param required [Boolean] Whether or not this attribute must be set. If required, and Lita
    #   is run without it set, a {Lita::ValidationError} will be raised.
    # @param default [Object] An optional default value for the attribute.
    # @yield A block to be evaluated in the context of the new attribute. Used for
    #   defining nested configuration attributes and validators.
    # @return [void]
    def config(name, types: nil, type: nil, required: false, default: nil)
      attribute = self.class.new
      attribute.name = name
      attribute.types = types || type
      attribute.required = required
      attribute.value = default
      attribute.instance_exec(&proc) if block_given?

      children << attribute
    end

    # Extracts the finalized configuration object as it will be interacted with by the user.
    # @param object [Object] The bare object that will be extended to create the final form.
    # @return [Object] A bare object with only the methods that were declared via the
    #   {Lita::Configuration} DSL.
    def finalize(object = Object.new)
      container = if children.empty?
        finalize_simple(object)
      else
        finalize_nested(object)
      end

      container.public_send(name)
    end

    # Sets the valid types for the configuration attribute.
    # @param types [Object, Array<Object>] One or more valid types.
    # @return [void]
    def types=(types)
      @types = Array(types) if types
    end

    # Declares a block to be used to validate the value of an attribute whenever it's set.
    # Validation blocks should return any object to indicate an error, or +nil+/+false+ if
    # validation passed.
    # @yield The code that performs validation.
    # @return [void]
    def validate
      @validator = proc
    end

    # Sets the value of the attribute, raising an error if it is not among the valid types.
    # @param value [Object] The new value of the attribute.
    # @return [void]
    # @raise [TypeError] If the new value is not among the declared valid types.
    def value=(value)
      if value && types && types.none? { |type| type === value }
        raise TypeError, I18n.t("lita.config.type_error", attribute: name, types: types.join(", "))
      end

      @value = value
    end

    private

    # Finalize the root object.
    def finalize_nested(object)
      this = self

      nested_object = Object.new
      children.each { |child| child.finalize(nested_object) }
      object.instance_exec { define_singleton_method(this.name) { nested_object } }

      object
    end

    # Finalize a nested object.
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
            Lita.logger.fatal(
              I18n.t("lita.config.type_error", attribute: this.name, types: this.types.join(", "))
            )
            abort
          end

          this.value = value
        end
      end

      object
    end
  end
end
