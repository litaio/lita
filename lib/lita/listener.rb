require "lita/handler"

module Lita
  class Listener < Handler
    def self.inherited(klass)
      Lita.listeners << klass
    end
  end
end
