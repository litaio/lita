module Lita
  module Adapters
    class Test < Adapter
    end

    Lita.register_adapter(:test, Test)
  end
end

Lita.config.adapter.name = :test
