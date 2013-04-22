require "spec_helper"

describe Lita::Config do
  describe ".default_config" do
    it "sets default configuration for a Lita instance" do
      config = described_class.default_config
      expect(config.robot.name).to eq("Lita")
    end
  end

  it "is indifferent to symbol and string keys" do
    subject["foo"] = "bar"
    expect(subject[:foo]).to eq("bar")
  end

  it "treats attribute access like a hash key" do
    subject.foo = "bar"
    expect(subject.foo).to eq("bar")
  end
end
