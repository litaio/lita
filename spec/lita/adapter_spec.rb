require "spec_helper"

describe Lita::Adapter do
  let(:robot) { double("Robot") }

  let(:required_methods) { [:run, :send_messages, :set_topic, :shut_down] }

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
  end
end
