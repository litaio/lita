require "spec_helper"

handler_class = Class.new(Lita::Handler) do
  namespace "testclass"

  def self.name
    "Lita::Handlers::Test"
  end
end

additional_handler_class = Class.new(Lita::Handler) do
  namespace "testclass"

  config :test_property, type: String, default: "a string"

  def self.name
    "Lita::Handlers::TestBase"
  end
end

describe handler_class, lita_handler: true, additional_lita_handlers: additional_handler_class do
  context 'when the "additional_lita_handlers" metadata is provided' do
    it "loads additional handlers into the registry" do
      expect(registry.handlers).to include(additional_handler_class)
    end

    it "populates config from additional handlers" do
      expect(registry.config.handlers.testclass.test_property).to eq("a string")
    end
  end
end
