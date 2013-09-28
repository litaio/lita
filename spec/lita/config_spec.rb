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

    it "loads configuration from registered schedulers" do
      scheduler = Class.new(Lita::Scheduler) do
        def self.default_config(scheduler_config)
          scheduler_config.bar = :baz
        end

        def self.name
          "Lita::schedulers::Foo"
        end
      end
      allow(Lita).to receive(:schedulers).and_return([scheduler])
      default_config = described_class.default_config
      expect(default_config.schedulers.foo.bar).to eq(:baz)
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
      expect(Lita.logger).to receive(:fatal).with(/could not be processed/)
      expect { described_class.load_user_config }.to raise_error(SystemExit)
    end
  end
end
