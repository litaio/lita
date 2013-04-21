require "spec_helper"

describe Lita do
  describe ".run" do
    let(:robot) { stub("robot") }

    it "runs a new robot" do
      Lita::Robot.should_receive(:new).and_return { robot }
      robot.should_receive(:run)
      Lita.run
    end
  end

  describe ".config" do
    it "returns a memoized Config instance" do
      config = Lita.config
      expect(config).to be_an_instance_of(Lita::Config)
      expect(config).to be(Lita.config)
    end
  end

  describe ".configure" do
    it "yields the config object to the provided block" do
      Lita.config.should_receive(:foo)
      Lita.configure { |config| config.foo }
    end
  end

  describe ".load_config" do
    it "returns the default config if no config file is present" do
      expect(Lita.load_config).to be(Lita.config)
    end

    it "runs the user config file" do
      File.stub(exist?: true)
      Lita.stub(:load) { Lita.configure { |config| config.foo } }
      Lita.config.should_receive(:foo)
      Lita.load_config
    end

    it "raises an exception if the user config file raises an exception" do
      File.stub(exist?: true)
      Lita.stub(:load) { Lita.non_existent_method }
      expect do
        Lita.load_config
      end.to raise_error(Lita::ConfigError)
    end
  end

  describe ".adapters" do
    it "returns a memoized hash of adapters" do
      adapters = Lita.adapters
      expect(adapters).to be_an_instance_of(Hash)
      expect(adapters).to be(Lita.adapters)
    end
  end

  describe ".listeners" do
    it "returns a memoized array of listeners" do
      listeners = Lita.listeners
      expect(listeners).to be_an_instance_of(Array)
      expect(listeners).to be(Lita.listeners)
    end
  end

  describe ".commands" do
    it "returns a memoized array of commands" do
      commands = Lita.commands
      expect(commands).to be_an_instance_of(Array)
      expect(commands).to be(Lita.commands)
    end
  end
end
