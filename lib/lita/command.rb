require "lita/handler"

module Lita
  class Command < Handler
    def self.inherited(klass)
      Lita.commands << klass
    end
  end
end
