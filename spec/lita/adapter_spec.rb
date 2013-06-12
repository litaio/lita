require "spec_helper"

describe Lita::Adapter do
  let(:robot) { double("Robot") }

  subject { described_class.new(robot) }

  it "stores a Robot" do
    expect(subject.robot).to eql(robot)
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
      expect do
        subject
      end.to raise_error(Lita::ConfigError, /foo, bar, baz, blah, bleh/)
    end
  end
end
