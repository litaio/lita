module Lita
  # Represents the action that is taken when a route or event is triggered. It
  # can be a block or the name of a method on object.
  # @api private
  class Callback
    # A block that should be used as the callback.
    attr_reader :block

    # The name of the method in the plugin that should be called as the callback.
    attr_reader :method_name

    def initialize(method_name_or_callable)
      if method_name_or_callable.respond_to?(:call)
        @block = method_name_or_callable
      else
        @method_name = method_name_or_callable
      end
    end

    # Invokes the callback.
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
