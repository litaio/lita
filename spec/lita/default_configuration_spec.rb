require "spec_helper"

describe Lita::DefaultConfiguration, lita: true do
  subject { described_class.new(registry) }

  let(:config) { subject.build }

  describe "adapter config" do
    it "is an old-style config object" do
      config.adapter.foo = "bar"

      expect(config.adapter.foo).to eq("bar")
    end

    it "prints a deprecation warning on access" do
      expect(Lita.logger).to receive(:warn).with(/config\.adapter is deprecated/)

      config.adapter.foo = "bar"
    end

    it "allows hash-style access" do
      config.adapter[:foo] = :bar

      expect(config.adapter["foo"]).to eq(:bar)
    end

    it "outputs one deprecation warning per hash-style access" do
      expect(Lita.logger).to receive(:warn).once

      config.adapter[:foo] = :bar
    end
  end

  describe "adapters config" do
    context "with no adapters with config attributes" do
      it "has an adapters attribute" do
        expect(config).to respond_to(:adapters)
      end
    end

    context "with one adapter with no configuration" do
      it "has an attribute for the adapter" do
        registry.register_adapter(:foo) {}
        expect(config.adapters).to respond_to(:foo)
      end
    end

    context "with an adapter with configuration" do
      it "has an attribute for the handler with its own attributes" do
        registry.register_adapter(:foo) { config :bar, default: :baz }

        expect(config.adapters.foo.bar).to eq(:baz)
      end
    end
  end

  describe "handlers config" do
    context "with no handlers with config attributes" do
      it "has a handlers attribute" do
        expect(config).to respond_to(:handlers)
      end
    end

    context "with one handler with no configuration" do
      it "has no attribute for the handler" do
        registry.register_handler(:foo) {}

        expect(config.handlers).not_to respond_to(:foo)
      end
    end

    context "with a handler with configuration" do
      it "has an attribute for the handler with its own attributes" do
        registry.register_handler(:foo) { config :bar, default: :baz }

        expect(config.handlers.foo.bar).to eq(:baz)
      end
    end

    context "with a handler defining default_config" do
      before do
        registry.register_handler(:foo) do
          def self.default_config(old_config)
            old_config.bar = :baz
          end
        end
      end

      it "has an attribute for the handler with its own attributes" do
        expect(config.handlers.foo.bar).to eq(:baz)
      end
    end
  end

  describe "http config" do
    it "has a default host" do
      expect(config.http.host).to eq("0.0.0.0")
    end

    it "can set the host" do
      config.http.host = "127.0.0.1"

      expect(config.http.host).to eq("127.0.0.1")
    end

    it "has a default port" do
      expect(config.http.port).to eq(8080)
    end

    it "can set the port" do
      config.http.port = 80

      expect(config.http.port).to eq(80)
    end

    it "has a default minimum thread count" do
      expect(config.http.min_threads).to eq(0)
    end

    it "can set the minimum threads" do
      config.http.min_threads = 4

      expect(config.http.min_threads).to eq(4)
    end

    it "has a default maximum thread count" do
      expect(config.http.max_threads).to eq(16)
    end

    it "can set the maximum threads" do
      config.http.max_threads = 8

      expect(config.http.max_threads).to eq(8)
    end

    it "has an empty middleware stack" do
      expect(config.http.middleware).to be_empty
    end

    it "can add middleware to the stack" do
      middleware = double("a rack middleware")

      config.http.middleware.push(middleware)

      expect(config.http.middleware).not_to be_empty
    end

    it "can add middleware with arguments" do
      middleware = double("a rack middleware")

      config.http.middleware.use(middleware, "argument") do
        "block"
      end

      expect(config.http.middleware).not_to be_empty
    end
  end

  describe "redis config" do
    it "has empty default options" do
      expect(config.redis).to eq({})
    end

    it "can set options" do
      options = { port: 1234, password: "secret" }

      config.redis = options

      expect(config.redis).to eq(options)
    end

    it "can set options with struct-style access" do
      config.redis.port = 1234

      expect(config.redis.port).to eq(1234)
    end

    it "prints a deprecation warning for struct-style access" do
      expect(Lita.logger).to receive(:warn).with(/struct-style access/i)

      config.redis.port = 1234
    end
  end

  describe "robot config" do
    it "has a default name" do
      expect(config.robot.name).to eq("Lita")
    end

    it "can set a name" do
      config.robot.name = "Not Lita"

      expect(config.robot.name).to eq("Not Lita")
    end

    it "has no default mention name" do
      expect(config.robot.mention_name).to be_nil
    end

    it "can set a mention name" do
      config.robot.mention_name = "notlita"

      expect(config.robot.mention_name).to eq("notlita")
    end

    it "has no default alias" do
      expect(config.robot.alias).to be_nil
    end

    it "can set an alias" do
      config.robot.alias = "/"

      expect(config.robot.alias).to eq("/")
    end

    it "has a default adapter" do
      expect(config.robot.adapter).to eq(:shell)
    end

    it "can set an adapter" do
      config.robot.adapter = :hipchat

      expect(config.robot.adapter).to eq(:hipchat)
    end

    it "has a default locale" do
      expect(config.robot.locale).to eq(I18n.locale)
    end

    it "can set a locale" do
      config.robot.locale = :es

      expect(config.robot.locale).to eq(:es)
    end

    it "has a default log level" do
      expect(config.robot.log_level).to eq(:info)
    end

    it "can set a log level" do
      config.robot.log_level = :debug

      expect(config.robot.log_level).to eq(:debug)
    end

    it "allows strings and mixed case as log levels" do
      expect { config.robot.log_level = "dEbUg" }.not_to raise_error
    end

    it "raises a validation error for invalid log levels" do
      expect(Lita.logger).to receive(:fatal).with(
        /Validation error on attribute "log_level": must be one of/
      )
      expect { config.robot.log_level = :not_a_level }.to raise_error(SystemExit)
    end

    it "has no default admins" do
      expect(config.robot.admins).to be_nil
    end

    it "can set admins" do
      config.robot.admins = %w(1 2 3)

      expect(config.robot.admins).to eq(%w(1 2 3))
    end
  end
end
