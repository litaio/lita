require "spec_helper"

describe Lita::Handler::ConfigDSL, lita: true do
  let(:robot) { Lita::Robot.new(registry) }

  let(:handler) do
    Class.new do
      extend Lita::Handler::ConfigDSL

      config :simple
      config :single_type, type: Symbol
      config :multiple_types, types: [Symbol, String]
      config :default_value, default: "anything"
    end
  end

  let(:config) { handler.config_builder.config }

  describe ".config" do
    it "creates simple config attributes" do
      config.simple = "simple value"
      expect(config.simple).to eq("simple value")
    end

    it "raises when setting a value that is not a valid type" do
      expect { config.single_type = "not a symbol" }.to raise_error(TypeError)
    end

    it "allows values that are one of the valid types" do
      config.multiple_types = "a string"
      expect(config.multiple_types).to eq("a string")
    end

    it "sets a default value" do
      expect(config.default_value).to eq("anything")
    end

    it "raises if the default value is not a valid type" do
      expect do
        handler.config :invalid_default, type: Symbol, default: "string"
      end.to raise_error(TypeError)
    end
  end
end
