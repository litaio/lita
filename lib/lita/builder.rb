module Lita
  class Builder
    def initialize(namespace, &block)
      @namespace = namespace.to_s
      @block = block
    end

    def build_adapter
      adapter = create_plugin(Adapter)
      adapter.class_exec(&@block)
      adapter
    end

    def build_handler
      handler = create_plugin(Handler)
      handler.instance_exec(&@block)
      handler
    end

    private

    def create_plugin(plugin_type)
      plugin = Class.new(plugin_type)
      plugin.namespace(@namespace)
      plugin
    end
  end
end
