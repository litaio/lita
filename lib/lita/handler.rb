module Lita
  class Handler
    def self.combined_getter_setter(name)
      singleton_class.send(:define_method, name) do |value = nil|
        if value.nil?
          defined?(instance_variable_get("@#{name}")) &&
            instance_variable_get("@#{name}")
        else
          instance_variable_set("@#{name}", value)
        end
      end
    end

    combined_getter_setter :match
    combined_getter_setter :description
    combined_getter_setter :storage_key

    def self.match?(message)
      match === message.body
    end
  end
end
