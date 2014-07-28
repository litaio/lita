module Lita
  class EventCallback
    attr_reader :block
    attr_reader :method_name

    def initialize(method_name_or_callable)
      if method_name_or_callable.respond_to?(:call)
        @block = method_name_or_callable
      else
        @method_name = method_name_or_callable
      end
    end

    def call(handler, payload)
      if block
        handler.instance_exec(payload, &block)
      else
        handler.public_send(method_name, payload)
      end

      true
    end
  end
end
