module Lita
  class ConfigBuilder
    attr_reader :config

    def initialize
      @config = Object.new
    end

    def add_attribute(attribute)
      define_getter(attribute)
      define_setter(attribute)
    end

    private

    def define_getter(attribute)
      @config.instance_exec do
        define_singleton_method(attribute.name) { attribute.get }
      end
    end

    def define_setter(attribute)
      @config.instance_exec do
        define_singleton_method("#{attribute.name}=") { |value| attribute.set(value) }
      end
    end
  end
end
