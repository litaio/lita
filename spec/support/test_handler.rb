module Lita
  module Handlers
    class Test < Handler
      route(/\w{3}/, to: :foo)
      route(/\w{4}/, to: :blah, command: true)

      def foo(matches)
      end

      def blah(matches)
      end
    end
  end
end
