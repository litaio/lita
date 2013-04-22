require "lita/util"

module Lita
  class Adapter
    def self.inherited(klass)
      class_key = Util.underscore(Util.demodulize(klass.name)).to_sym
      Lita.adapters[class_key] = klass
    end

    def self.load_adapter(key)
      Lita.adapters[key.to_sym]
    end
  end
end
