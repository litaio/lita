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
      expect(described_class.default_config.robot.adapter).to eq(:shell)
    end
  end

  describe ".load_user_config" do
    it "loads and evals lita_config.rb" do
      allow(File).to receive(:exist?).and_return(true)
      allow(described_class).to receive(:load) do
        Lita.configure { |config| config.robot.name = "Not Lita" }
      end
      described_class.load_user_config
      expect(Lita.config.robot.name).to eq("Not Lita")
    end

    it "doesn't attempt to load lita_config.rb if it doesn't exist" do
      expect(described_class).not_to receive(:load)
      described_class.load_user_config
    end

    it "raises an exception if lita_config.rb raises an exception" do
      allow(File).to receive(:exist?).and_return(true)
      allow(described_class).to receive(:load) { Lita.non_existent_method }
      expect do
        described_class.load_user_config
      end.to raise_error(Lita::ConfigError)
    end
  end
end
