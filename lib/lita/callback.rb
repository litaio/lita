module Lita
  class Callback
    attr_reader :block
    attr_reader :method_name

    def initialize(method_name_or_callable)
      if method_name_or_callable.respond_to?(:call)
        @block = method_name_or_callable
      else
        @method_name = method_name_or_callable
      end
    end

    def call(host, *args)
      if block
        host.instance_exec(*args, &block)
      else
        host.public_send(method_name, *args)
      end

      true
    end
  end
end
