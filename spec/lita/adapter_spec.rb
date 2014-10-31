require "spec_helper"

describe Lita::Adapter, lita: true do
  let(:robot) { Lita::Robot.new(registry) }

  let(:required_methods) { [:join, :part, :run, :send_messages, :set_topic, :shut_down] }

  subject { described_class.new(robot) }

  it "stores a Robot" do
    expect(subject.robot).to eql(robot)
  end

  it "logs a warning if a required method has not been implemented" do
    expect(Lita.logger).to receive(:warn).exactly(required_methods.size).times
    required_methods.each do |method|
      subject.public_send(method)
    end
  end

  describe ".require_config" do
    let(:adapter_class) do
      Class.new(described_class) do
        require_config :foo
        require_configs :bar, :baz
        require_configs ["blah", :bleh]
      end
    end

    subject { adapter_class.new(robot) }

    it "ensures that config keys are present on initialization" do
      expect(Lita.logger).to receive(:fatal).with(/foo, bar, baz, blah, bleh/)
      expect { subject }.to raise_error(SystemExit)
    end

    it "logs a deprecation warning when the adapter is initialized" do
      expect(Lita.logger).to receive(:warn).with(/Use Lita::Adapter\.config instead/)

      expect { adapter_class.new(robot) }.to raise_error(SystemExit)
    end
  end

  describe "#config" do
    let(:adapter) do
      Class.new(described_class) do
        namespace "test"

        config :foo, default: :bar
      end
    end

    let(:robot) { Lita::Robot.new(registry) }

    before { registry.register_adapter(:test, adapter) }

    subject { adapter.new(robot) }

    it "provides access to the adapter's configuration object" do
      expect(subject.config.foo).to eq(:bar)
    end
  end

  describe "#log" do
    it "returns the Lita logger" do
      expect(subject.log).to eq(Lita.logger)
    end
  end

  describe "#mention_format" do
    it "formats the provided name for mentioning the user" do
      expect(subject.mention_format("carl")).to eq("carl:")
    end
  end
end
