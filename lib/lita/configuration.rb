module Lita
  class Configuration
    attr_reader :types
    attr_reader :value

    attr_accessor :children
    attr_accessor :name
    attr_accessor :parent
    attr_accessor :validator

    def initialize
      self.children = []
    end

    def config(name, types: nil, type: nil, default: nil, &block)
      self.name = name

      if block
        child_config = self.class.new
        child_config.parent = self
        child_config.instance_exec(&block)
      else
        self.types = types || type
        self.value = default

        parent.children << self if parent
      end
    end

    def finalize(object = Object.new)
      if children.empty?
        finalize_simple(object)
      else
        finalize_nested(object)
      end
    end

    def types=(types)
      @types = Array(types) if types
    end

    def validate(&block)
      parent.validator = block
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
