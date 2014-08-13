require "spec_helper"

describe Lita::Handler::Common, lita: true do
  let(:robot) { Lita::Robot.new(registry) }

  let(:handler) do
    Class.new do
      include Lita::Handler::Common

      def self.name
        "Lita::Handlers::FooBarBaz"
      end

      def self.default_config(config)
        config.foo = "bar"
      end
    end
  end

  subject { handler.new(robot) }

  describe ".config" do
    it "delegates to the ConfigDSL object" do
      expect(handler.config_dsl).to receive(:config).with(:foo, type: Symbol, default: :bar)

      handler.config(:foo, type: Symbol, default: :bar)
    end
  end

  describe ".namespace" do
    it "returns a snake cased namesapce for the handler based on class name" do
      expect(handler.namespace).to eq("foo_bar_baz")
    end

    it "allows the namespace to be set with an object" do
      handler = Class.new do
        include Lita::Handler::Common

        namespace "Lita::Handler::Common"
      end

      expect(handler.namespace).to eq("common")
    end

    it "raises an exception if the handler doesn't have a name to derive the namespace from" do
      handler = Class.new { include Lita::Handler::Common }
      expect { handler.namespace }.to raise_error
    end
  end

  describe "#config" do
    before do
      allow(Lita).to receive(:handlers).and_return([handler])
      registry.register_handler(handler)
    end

    it "returns the handler's config settings" do
      expect(subject.config.foo).to eq("bar")
    end
  end

  describe "#log" do
    it "returns the Lita logger" do
      expect(subject.log).to eq(Lita.logger)
    end
  end
end
