require "rspec/core"

module Lita
  module RSpec
    def self.included(base)
      base.instance_eval do
        let(:robot) { Robot.new(config) }

        let(:config) do
          config = Config.default_config
          config.adapter.name = :test
          config
        end

        let(:user) { User.new(robot, "Test User") }
      end

      base.class_eval do
        def chat(message, author = nil)
          author ||= user
          robot.receive(Message.new(message, author))
        end

        def handles(message)
          PositiveRoute.new(self, message)
        end

        def does_not_handle(message)
          NegativeRoute.new(self, message)
        end
        alias_method :doesnt_handle, :does_not_handle
      end
    end

    class PositiveRoute < Struct.new(:context, :message)
      def with(route)
        context.described_class.any_instance.should_receive(route)
        context.chat(message)
      end
    end

    class NegativeRoute < Struct.new(:context, :message)
      def with(route)
        context.described_class.any_instance.should_not_receive(route)
        context.chat(message)
      end
    end
  end
end

RSpec.configure do |config|
  config.include Lita::RSpec, lita_handler: true

  config.before(:each, lita_handler: true) do
    Lita::Adapter.stub(:load_adapter) { Class.new(Lita::Adapter) }
    Lita.stub(:handlers) { [described_class] }
  end
end
