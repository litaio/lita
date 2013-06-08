module Lita
  module Handlers
    class Test < Handler
      route(/\w{3}/, to: :foo)
      route(/\w{4}/, to: :blah, command: true)
      route(/args/, to: :test_args)

      def foo(matches)
      end

      def blah(matches)
      end

      def test_args(matches)
        say args
      end
    end
  end
end
