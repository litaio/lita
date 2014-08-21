require "spec_helper"

describe Lita::Config do
  let(:value) { double("arbitrary config key's value") }

  it "allows hash-style access with symbols or strings" do
    subject[:foo] = value
    expect(subject[:foo]).to eql(value)
    expect(subject["foo"]).to eql(value)
  end

  it "allows struct-style access" do
    subject.foo = value
    expect(subject.foo).to eql(value)
  end

  describe ".default_config" do
    it "has predefined values for certain keys" do
      default_config = described_class.default_config
      expect(default_config.robot.name).to eq("Lita")
      expect(default_config.robot.adapter).to eq(:shell)
    end

    it "loads configuration from registered handlers" do
      handler = Class.new(Lita::Handler) do
        def self.default_config(handler_config)
          handler_config.bar = :baz
        end

        def self.name
          "Lita::Handlers::Foo"
        end
      end
      allow(Lita).to receive(:handlers).and_return([handler])
      default_config = described_class.default_config
      expect(default_config.handlers.foo.bar).to eq(:baz)
    end
  end

  describe "#finalize" do
    it "freezes the configuration" do
      subject.finalize
      expect { subject.robot = "Assignment is impossible!" }.to raise_error(RuntimeError, /frozen/)
    end
  end
end
