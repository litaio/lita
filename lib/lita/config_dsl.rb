module Lita
  class ConfigDSL
    attr_reader :builder

    def initialize
      @builder = ConfigBuilder.new
    end

    def builder_config
      builder.config
    end

    def config(name, types: nil, type: nil, default: nil, &block)
      types = Array(types || type)

      if block
        nested = self.class.new
        nested.instance_exec(&block)
        attribute = new_attribute(name, [], nested.builder_config)
      else
        attribute = new_attribute(name, types, default)
      end

      builder.add_attribute(attribute)
    end

    private

    def new_attribute(name, types, default)
      attribute = ConfigAttribute.new(name)
      attribute.types = types unless types.empty?
      attribute.set(default) if default
      attribute
    end
  end
end
