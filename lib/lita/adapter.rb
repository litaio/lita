require "lita/util"

module Lita
  module Adapter
    class << self
      def load_adapter(key)
        Lita.adapters[key.to_sym] or raise UnknownAdapterError.new(
          %{No adapter has been registered under the key "#{key}".}
        )
      end
    end

    class Base
      attr_reader :robot

      class << self
        def inherited(klass)
          adapter_key = Util.underscore(Util.demodulize(klass.name))
          Lita.adapters[adapter_key.to_sym] = klass
        end
      end

      def initialize(robot)
        @robot = robot
      end
    end
  end
end
