require "spec_helper"

describe Lita do
  before do
    Lita.instance_variable_set(:@config, nil)
    Lita.instance_variable_set(:@logger, nil)
  end

  it "memoizes a hash of Adapters" do
    adapter_class = double("Adapter")
    described_class.register_adapter(:foo, adapter_class)
    expect(described_class.adapters[:foo]).to eql(adapter_class)
    expect(described_class.adapters).to eql(described_class.adapters)
  end

  it "memoizes a set of Handlers" do
    handler_class = double("Handler")
    described_class.register_handler(handler_class)
    described_class.register_handler(handler_class)
    original_size = described_class.handlers.to_a.size
    new_size = (described_class.handlers.to_a - [handler_class]).size
    expect(new_size).to eq(original_size - 1)
    expect(described_class.handlers).to eql(described_class.handlers)
  end

  it "memoizes a Config" do
    expect(described_class.config).to be_a(Lita::Config)
    expect(described_class.config).to eql(described_class.config)
  end

  describe ".configure" do
    it "yields the Config object" do
      described_class.configure { |c| c.robot.name = "Not Lita" }
      expect(described_class.config.robot.name).to eq("Not Lita")
    end
  end

  describe ".logger" do
    it "memoizes the logger" do
      expect(described_class.logger).to be_a(Logger)
      expect(described_class.logger).to eql(described_class.logger)
    end

    it "uses a custom log level" do
      Lita.config.robot.log_level = :debug
      expect(described_class.logger.level).to eq(Logger::DEBUG)
    end

    it "uses the info level if the config is nil" do
      Lita.config.robot.log_level = nil
      expect(described_class.logger.level).to eq(Logger::INFO)
    end

    it "uses the info level if the config level is invalid" do
      Lita.config.robot.log_level = :foo
      expect(described_class.logger.level).to eq(Logger::INFO)
    end

    it "logs messages with a custom format" do
      stderr = StringIO.new
      stub_const("STDERR", stderr)
      Lita.logger.fatal "foo"
      expect(stderr.string).to match(%r{^\[.+\] FATAL: foo$})
    end
  end

  describe ".redis" do
    it "memoizes a Redis::Namespace" do
      expect(described_class.redis).to respond_to(:namespace)
      expect(described_class.redis).to eql(described_class.redis)
    end
  end

  describe ".run" do
    before { Lita.config }

    it "runs a new Robot" do
      expect_any_instance_of(Lita::Robot).to receive(:run)
      described_class.run
    end
  end
end
