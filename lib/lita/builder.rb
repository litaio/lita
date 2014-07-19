module Lita
  class Builder
    def initialize(namespace, &block)
      @namespace = namespace.to_s
      @block = block
    end

    def build_handler
      build(Handler)
    end

    private

    def build(plugin_type)
      plugin = Class.new(plugin_type)
      plugin.namespace(@namespace)
      plugin.instance_exec(&@block)
      plugin
    end
  end
end
