module Lita
  class Configuration
    attr_reader :children
    attr_reader :types
    attr_reader :validator

    attr_accessor :name
    attr_accessor :value

    def initialize
      @children = []
      @name = :root
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
