module Lita
  module RSpec
    module Matchers
      # Lita 3 versions of the routing  matchers.
      # @deprecated Will be removed in Lita 5.0. Use the +is_expected+ forms instead.
      class Deprecated
        # @param context [RSpec::ExampleGroup] The example group where the matcher was called.
        # @param new_method_name [String, Symbol] The method that should be used instead.
        # @param positive [Boolean] Whether or not a positive expectation is being made.
        def initialize(context, new_method_name, positive, *args)
          @context = context
          @new_method_name = new_method_name
          @expectation_method_name = positive ? :to : :not_to
          @args = args

          @context.instance_exec do
            allow_any_instance_of(Authorization).to receive(:user_in_group?).and_return(true)
          end
        end

        # Sets an expectation that the previously supplied message will route to the provided
        # method.
        # @param method_name [String, Symbol] The name of the method that should be routed to.
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
