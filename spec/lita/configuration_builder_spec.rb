require "spec_helper"

describe Lita::ConfigurationBuilder do
  let(:config) { subject.build }

  describe ".load_user_config" do
    it "loads and evals lita_config.rb" do
      allow(File).to receive(:exist?).and_return(true)
      allow(described_class).to receive(:load) do
        Lita.configure { |c| c.robot.name = "Not Lita" }
      end
      described_class.load_user_config
      expect(Lita.config.robot.name).to eq("Not Lita")
    end

    it "doesn't attempt to load lita_config.rb if it doesn't exist" do
      allow(File).to receive(:exist?).and_return(false)
      expect(described_class).not_to receive(:load)
      described_class.load_user_config
    end

    it "raises an exception if lita_config.rb raises an exception" do
      allow(File).to receive(:exist?).and_return(true)
      allow(described_class).to receive(:load) { Lita.non_existent_method }
      expect(Lita.logger).to receive(:fatal).with(/could not be processed/)
      expect { described_class.load_user_config }.to raise_error(SystemExit)
    end
  end

  describe "a simple attribute" do
    before { subject.config :simple }

    it "is nil by default" do
      expect(config.simple).to be_nil
    end

    it "can be set to anything" do
      config.simple = 1
      expect(config.simple).to eq(1)
    end
  end

  describe "a typed attribute" do
    before { subject.config :simple, type: Symbol }

    it "is nil by default" do
      expect(config.simple).to be_nil
    end

    it "can be set to a value of the type" do
      config.simple = :foo
      expect(config.simple).to eq(:foo)
    end

    it "raises if set to a value of the wrong type" do
      expect(Lita.logger).to receive(:fatal).with(
        /Configuration type error: "simple" must be one of: Symbol/
      )
      expect { config.simple = "foo" }.to raise_error(SystemExit)
    end
  end

  describe "a composite typed attribute" do
    before { subject.config :simple, types: [Symbol, String] }

    it "is nil by default" do
      expect(config.simple).to be_nil
    end

    it "can be set to a value of the first type" do
      config.simple = :foo
      expect(config.simple).to eq(:foo)
    end

    it "can be set to a value of the second type" do
      config.simple = "foo"
      expect(config.simple).to eq("foo")
    end

    it "raises if set to a value of the wrong type" do
      expect(Lita.logger).to receive(:fatal).with(
        /Configuration type error: "simple" must be one of: Symbol, String/
      )
      expect { config.simple = 1 }.to raise_error(SystemExit)
    end
  end

  describe "an attribute with a default value" do
    before { subject.config :simple, default: :foo }

    it "starts with the default value" do
      expect(config.simple).to eq(:foo)
    end

    it "can be reassigned" do
      config.simple = :bar
      expect(config.simple).to eq(:bar)
    end
  end

  describe "a typed attribute with a default value" do
    it "starts with the default value" do
      subject.config :simple, type: Symbol, default: :foo
      expect(config.simple).to eq(:foo)
    end

    it "raises if the default is a value of the wrong type" do
      expect { subject.config :simple, type: Symbol, default: "foo" }.to raise_error(TypeError)
    end
  end

  describe "a validated attribute" do
    before do
      subject.config :simple do
        validate { |value| "must be true" unless value }
      end
    end

    it "can be set to a value that passes validation" do
      config.simple = true
      expect(config.simple).to be(true)
    end

    it "raises if the validator raises due to an invalid value" do
      expect(Lita.logger).to receive(:fatal).with(
        /Validation error on attribute "simple": must be true/
      )
      expect { config.simple = false }.to raise_error(SystemExit)
    end
  end

  describe "a validated attribute with a conflicting default value" do
    it "raises a ValidationError" do
      expect do
        subject.config :simple, default: :foo do
          validate { |value| "must be :bar" unless value == :bar }
        end
      end.to raise_error(Lita::ValidationError, /must be :bar/)
    end
  end

  describe "a simple nested attribute" do
    before do
      subject.config :nested do
        config :foo
      end
    end

    it "is nil by default" do
      expect(config.nested.foo).to be_nil
    end

    it "can be set to anything" do
      config.nested.foo = :bar
      expect(config.nested.foo).to eq(:bar)
    end

    it "prevents the parent from being assigned" do
      expect { config.nested = "impossible" }.to raise_error(NoMethodError)
    end
  end

  describe "an attribute with all the options and nested attributes" do
    before do
      subject.config :nested, type: Symbol, default: :foo do
        config :foo
      end
    end

    it "cannot be set" do
      expect { config.nested = "impossible" }.to raise_error(NoMethodError)
    end
  end

  describe "multiple nested attributes with options" do
    before do
      subject.config :nested do
        config :foo, default: "bar" do
          validate { |value| "must include bar" unless value.include?("bar") }
        end

        config :bar, type: Symbol
      end
    end

    it "can get the first nested attribute" do
      expect(config.nested.foo).to eq("bar")
    end

    it "can set the first nested attribute" do
      config.nested.foo = "foo bar baz"
      expect(config.nested.foo).to eq("foo bar baz")
    end

    it "has working validation" do
      expect(Lita.logger).to receive(:fatal).with(
        /Validation error on attribute "foo": must include bar/
      )
      expect { config.nested.foo = "baz" }.to raise_error(SystemExit)
    end

    it "can get the second nested attribute" do
      expect(config.nested.bar).to be_nil
    end

    it "can set the second nested attribute and options take effect" do
      expect(Lita.logger).to receive(:fatal).with(
        /Configuration type error: "bar" must be one of: Symbol/
      )
      expect { config.nested.bar = "not a symbol" }.to raise_error(SystemExit)
    end
  end

  describe "#has_children?" do
    it "is true when any attribute has been created" do
      subject.config :foo

      expect(subject.children?).to be_truthy
    end

    it "is false when no attributes have been created" do
      expect(subject.children?).to be_falsy
    end
  end

  describe "#combine" do
    let(:config_2) do
      config_2 = described_class.new
      config_2.config(:bar)
      config_2
    end

    it "sets the provided configuration as the value of the provided attribute" do
      subject.combine(:foo, config_2)

      expect(config.foo.bar).to be_nil
    end

    it "does not allow the combined configuration to be reassigned" do
      subject.combine(:foo, config_2)

      expect { config.foo = "bar" }.to raise_error(NoMethodError)
    end
  end
end
