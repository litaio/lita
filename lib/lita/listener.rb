module Lita
  module Listener
    class Base
      class << self
        def inherited(klass)
          Lita.listeners << klass
        end
      end
    end
  end
end

require "lita/listener/echo"
