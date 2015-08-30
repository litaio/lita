require "spec_helper"

describe Lita::Adapter, lita: true do
  let(:robot) { Lita::Robot.new(registry) }

  let(:required_methods) { described_class::REQUIRED_METHODS }

  subject { described_class.new(robot) }

  it "stores a Robot" do
    expect(subject.robot).to eql(robot)
  end

  it "logs a warning if a required method has not been implemented" do
    expect(robot.logger).to receive(:warn).exactly(required_methods.size).times
    required_methods.each do |method|
      subject.public_send(method)
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
    it "returns the robot's logger" do
      expect(subject.log).to eq(robot.logger)
    end
  end

  describe "#mention_format" do
    it "formats the provided name for mentioning the user" do
      expect(subject.mention_format("carl")).to eq("carl:")
    end
  end
end
