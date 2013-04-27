require "spec_helper"

describe Lita::Adapter do
  describe ".load_adapter" do
    let(:adapter_class) { double("adapter class") }

    before { Lita.register_adapter(:test_adapter, adapter_class) }

    after { Lita.reset_registry }

    it "returns an adapter class from the registry for the given symbol" do
      expect(described_class.load_adapter(:test_adapter)).to eq(adapter_class)
    end

    it "allows the adapter key to be a string" do
      expect(described_class.load_adapter("test_adapter")).to eq(adapter_class)
    end
  end
end
