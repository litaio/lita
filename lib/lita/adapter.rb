module Lita
  class Adapter
    def self.load_adapter(key)
      Lita.adapters[key.to_sym]
    end
  end
end
