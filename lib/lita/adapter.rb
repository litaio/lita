require "lita/util"

module Lita
  class Adapter
    class << self
      def inherited(klass)
        adapter_key = Util.underscore(Util.demodulize(klass.name)).to_sym
        Lita.adapters[adapter_key] = klass
      end

      def load_adapter(key)
        Lita.adapters[key.to_sym] or raise UnknownAdapterError.new(
          %{No adapter has been registered under the key "#{key}".}
        )
      end
    end

    attr_reader :robot

    def initialize(robot)
      @robot = robot
    end
  end
end
