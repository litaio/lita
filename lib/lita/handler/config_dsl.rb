module Lita
  class Handler
    module ConfigDSL
      attr_accessor :config_builder

      def self.extended(base)
        base.config_builder = ConfigBuilder.new
      end

      def config(name, types: nil, type: nil, default: nil)
        types = Array(types || type)

        attribute = ConfigAttribute.new(name)
        attribute.types = types unless types.empty?
        attribute.set(default) if default

        config_builder.add_attribute(attribute)
      end
    end
  end
end
