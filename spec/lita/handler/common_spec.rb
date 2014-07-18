require "spec_helper"

describe Lita::Handler::Common, lita: true do
  let(:robot) { instance_double("Lita::Robot") }

  let(:handler) do
    Class.new do
      include Lita::Handler::Common

      def self.name
        "Test"
      end

      def self.default_config(config)
        config.foo = "bar"
      end
    end
  end

  subject { handler.new(robot) }

  describe "#config" do
    before do
      Lita.register_handler(handler)
      Lita.reset_config
    end

    it "returns the handler's config settings" do
      expect(subject.config.foo).to eq("bar")
    end
  end

  describe "#log" do
    it "returns the Lita logger" do
      expect(subject.log).to eq(Lita.logger)
    end
  end
end
