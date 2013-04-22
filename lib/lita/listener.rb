module Lita
  class Listener
    def self.inherited(klass)
      Lita.listeners << klass
    end
  end
end
