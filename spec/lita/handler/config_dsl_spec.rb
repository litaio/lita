require "spec_helper"

describe Lita::Handler::ConfigDSL do
  let(:subject) { Class.new { extend Lita::Handler::ConfigDSL } }
  let(:config) { subject.config_builder.config }

  describe ".config" do
    it "creates simple config attributes" do
      subject.config :simple

      config.simple = "simple value"

      expect(config.simple).to eq("simple value")
    end

    it "raises when setting a value that is not a valid type" do
      subject.config :single_type, type: Symbol

      expect { config.single_type = "not a symbol" }.to raise_error(TypeError)
    end

    it "allows values that are one of the valid types" do
      subject.config :multiple_types, types: [Symbol, String]

      config.multiple_types = "a string"

      expect(config.multiple_types).to eq("a string")
    end

    it "sets a default value" do
      subject.config :default_value, default: "anything"

      expect(config.default_value).to eq("anything")
    end

    it "raises if the default value is not a valid type" do
      expect do
        subject.config :invalid_default, type: Symbol, default: "string"
      end.to raise_error(TypeError)
    end
  end
end
