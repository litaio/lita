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

describe handler_class, lita_handler: true, additional_lita_handlers: [additional_handler_class] do
  describe ":additional_lita_handlers" do
    it "loads additional handlers into registry" do
      expect(registry.handlers.include?(additional_handler_class)).to be true
    end

    it "populates config from additional handlers" do
      expect(registry.config.handlers.testclass.nil?).to be false
      expect(registry.config.handlers.testclass.test_property.nil?).to be false
    end
  end
end
