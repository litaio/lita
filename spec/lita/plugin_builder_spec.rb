require "spec_helper"

describe Lita::PluginBuilder, lita: true do
  let(:robot) { instance_double("Lita::Robot") }
  subject { plugin.new(robot) }

  describe "#build_adapter" do
    let(:builder) do
      described_class.new(:test_adapter) do
        def run
          self.class.namespace
        end
      end
    end

    let(:plugin) { builder.build_adapter }

    it "builds an adapter" do
      expect(subject.run).to eq("test_adapter")
    end
  end

  describe "#build_handler" do
    builder = described_class.new(:test_handler) do
      route(/namespace/) { |response| response.reply(self.class.namespace) }
    end

    plugin = builder.build_handler

    describe plugin, lita_handler: true do
      before { registry.register_handler(plugin) }

      it "builds a handler from a block" do
        send_message("namespace")
        expect(replies.last).to eq("test_handler")
      end
    end
  end
end
