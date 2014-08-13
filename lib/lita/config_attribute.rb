module Lita
  class ConfigAttribute
    attr_reader :name
    attr_reader :types
    attr_reader :value

    alias_method :get, :value

    def initialize(name)
      @name = name.to_s.strip.downcase.gsub(/\s+/, "_").to_sym
    end

    def set(value)
      if types && types.none? { |type| type === value }
        raise TypeError, "#{name} must be one of: #{types.inspect}"
      end

      @value = value
    end

    def types=(types)
      @types = Array(types)
    end
  end
end
