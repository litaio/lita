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
      expect(described_class.default_config.robot.name).to eq("Lita")
      expect(described_class.default_config.adapter.name).to eq(:shell)
    end
  end
end
