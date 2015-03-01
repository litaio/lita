require "spec_helper"

describe Lita do
  before { described_class.register_adapter(:shell, Lita::Adapters::Shell) }

  it "memoizes a Configuration" do
    expect(described_class.config).to eql(described_class.config)
  end

  it "keeps track of registered hooks" do
    hook = double("hook")
    described_class.register_hook("Foo ", hook)
    described_class.register_hook(:foO, hook)
    expect(described_class.hooks[:foo]).to eq(Set.new([hook]))
  end

  describe ".configure" do
    it "yields the Configuration object" do
      described_class.configure { |c| c.robot.name = "Not Lita" }
      expect(described_class.config.robot.name).to eq("Not Lita")
    end
  end

  describe ".load_locales" do
    let(:load_path) do
      load_path = double("Array")
      allow(load_path).to receive(:concat)
      load_path
    end

    let(:new_locales) { %w(foo bar) }

    before do
      allow(I18n).to receive(:load_path).and_return(load_path)
      allow(I18n).to receive(:reload!)
    end

    it "appends the locale files to I18n.load_path" do
      expect(I18n.load_path).to receive(:concat).with(new_locales)
      described_class.load_locales(new_locales)
    end

    it "reloads I18n" do
      expect(I18n).to receive(:reload!)
      described_class.load_locales(new_locales)
    end

    it "wraps single paths in an array" do
      expect(I18n.load_path).to receive(:concat).with(["foo"])
      described_class.load_locales("foo")
    end
  end

  describe ".locale=" do
    it "sets I18n.locale to the normalized locale" do
      expect(I18n).to receive(:locale=).with("es-MX.UTF-8")
      described_class.locale = "es_MX.UTF-8"
    end
  end

  describe ".redis" do
    let(:redis_namespace) { instance_double("Redis") }

    before do
      if described_class.instance_variable_defined?(:@redis)
        described_class.remove_instance_variable(:@redis)
      end

      allow(redis_namespace).to receive(:ping).and_return("PONG")
      allow(Redis::Namespace).to receive(:new).and_return(redis_namespace)
    end

    it "memoizes a Redis::Namespace" do
      expect(described_class.redis).to equal(redis_namespace)
      expect(described_class.redis).to eql(described_class.redis)
    end

    it "raises a RedisError if it can't connect to Redis" do
      allow(redis_namespace).to receive(:ping).and_raise(Redis::CannotConnectError)
      expect { Lita.redis }.to raise_error(Lita::RedisError, /could not connect to Redis/)
    end

    context "with test mode off" do
      around do |example|
        test_mode = Lita.test_mode?
        Lita.test_mode = false
        example.run
        Lita.test_mode = test_mode
      end

      it "logs a fatal warning and raises an exception if it can't connect to Redis" do
        allow(redis_namespace).to receive(:ping).and_raise(Redis::CannotConnectError)

        expect(Lita.logger).to receive(:fatal)
        expect { Lita.redis }.to raise_error(SystemExit)
      end
    end
  end

  describe ".register_adapter" do
    let(:robot) { instance_double("Lita::Robot") }

    it "builds an adapter out of a provided block" do
      described_class.register_adapter(:foo) {}
      expect(Lita.logger).to receive(:warn).with(/not implemented/)
      Lita.adapters[:foo].new(robot).run
    end

    it "raises if a non-class object is passed as the adapter" do
      expect do
        described_class.register_adapter(:foo, :bar)
      end.to raise_error(ArgumentError, /requires a class/)
    end
  end

  describe ".register_handler" do
    it "builds a handler out of a provided block" do
      described_class.register_handler(:foo) {}
      expect(described_class.handlers.to_a.last.namespace).to eq("foo")
    end

    it "raises if a non-class object is the only argument" do
      expect do
        described_class.register_handler(:foo)
      end.to raise_error(ArgumentError, /requires a class/)
    end
  end

  describe ".reset" do
    it "clears the config" do
      described_class.config.robot.name = "Foo"
      described_class.reset
      expect(described_class.config.robot.name).to eq("Lita")
    end

    it "clears adapters" do
      described_class.register_adapter(:foo, Class.new)
      described_class.reset
      expect(described_class.adapters).to be_empty
    end

    it "clears handlers" do
      described_class.register_handler(Class.new)
      described_class.reset
      expect(described_class.handlers).to be_empty
    end

    it "clears hooks" do
      described_class.register_hook(:foo, double)
      described_class.reset
      expect(described_class.hooks).to be_empty
    end
  end

  describe ".run" do
    let(:hook) { double("Hook") }
    let(:validator) { instance_double("Lita::ConfigurationValidator", call: nil) }

    before do
      allow_any_instance_of(Lita::Robot).to receive(:run)
      allow(Lita::ConfigurationValidator).to receive(:new).with(described_class).and_return(
        validator
       )
    end

    after { described_class.reset }

    it "runs a new Robot" do
      expect_any_instance_of(Lita::Robot).to receive(:run)
      described_class.run
    end

    it "calls before_run hooks" do
      described_class.register_hook(:before_run, hook)
      expect(hook).to receive(:call).with(config_path: "path/to/config")
      described_class.run("path/to/config")
    end

    it "calls config_finalized hooks" do
      described_class.register_hook(:config_finalized, hook)
      expect(hook).to receive(:call).with(config_path: "path/to/config")
      described_class.run("path/to/config")
    end

    it "raises if the configuration is not valid" do
      allow(validator).to receive(:call).and_raise(SystemExit)

      expect { described_class.run }.to raise_error(SystemExit)
    end
  end
end
