module Lita
  class ConfigDSL
    attr_reader :builder

    def initialize
      @builder = ConfigBuilder.new
    end

    def config(name, types: nil, type: nil, default: nil)
      types = Array(types || type)
      attribute = new_attribute(name, types, default)
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
