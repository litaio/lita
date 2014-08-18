require "spec_helper"

describe Lita::DefaultConfiguration do
  let(:config) { subject.finalize }

  describe "adapter config" do
    it "is an old-style config object" do
      config.adapter.foo = "bar"

      expect(config.adapter.foo).to eq("bar")
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

    it "raises a validation error for invalid log levels" do
      expect { config.robot.log_level = :not_a_level }.to raise_error(Lita::ValidationError)
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
