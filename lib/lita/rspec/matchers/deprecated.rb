module Lita
  module RSpec
    module Matchers
      class Deprecated
        def initialize(context, new_method_name, positive, *args)
          @context = context
          @new_method_name = new_method_name
          @expectation_method_name = positive ? :to : :not_to
          @args = args

          @context.instance_exec do
            allow_any_instance_of(Authorization).to receive(:user_in_group?).and_return(true)
          end
        end

        def to(method_name)
          emn = @expectation_method_name
          matcher = @context.public_send(@new_method_name, *@args)
          matcher.to(method_name)

          @context.instance_exec do
            is_expected.public_send(emn, matcher)
          end
        end
      end
    end
  end
end
