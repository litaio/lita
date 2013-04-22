module Lita
  class Command
    def self.inherited(klass)
      Lita.commands << klass
    end
  end
end
