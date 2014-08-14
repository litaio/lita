require "spec_helper"

describe Lita::Configuration do
  let(:config) { subject.finalize }

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
      expect { config.simple = "foo" }.to raise_error(TypeError)
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
      expect { config.simple = 1 }.to raise_error(TypeError)
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
        validate { |value| raise TypeError, "must be true" unless value }
      end
    end

    it "can be set to a value that passes validation" do
      config.simple = true
      expect(config.simple).to be(true)
    end

    it "raises if the validator raises due to an invalid value" do
      expect { config.simple = false }.to raise_error(TypeError, "must be true")
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

  describe "an attribute with all the options, validation, and nested attributes" do
    before do
      subject.config :nested, type: Symbol, default: :foo do
        validate { raise TypeError, "validation error" }

        config :foo
      end
    end

    it "cannot be set" do
      expect { config.nested = "impossible" }.to raise_error(NoMethodError)
    end
  end
end
