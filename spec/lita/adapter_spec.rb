require "spec_helper"

describe Lita::Adapter do
  describe ".load_adapter" do

    let!(:adapter_klass) do
      module Lita
        class TestAdapter < Adapter
        end
      end

      Lita::TestAdapter
    end

    after do
      Lita.adapters.delete(:test_adapter)
      Lita.send(:remove_const, :TestAdapter)
    end

    it "returns an adapter class from the registry for the given symbol" do
      expect(described_class.load_adapter(:test_adapter)).to eq(adapter_klass)
    end

    it "allows the adapter key to be a string" do
      expect(described_class.load_adapter("test_adapter")).to eq(adapter_klass)
    end
  end
end
