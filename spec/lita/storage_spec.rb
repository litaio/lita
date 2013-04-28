require "spec_helper"

describe Lita::Storage do
  describe "#namespaced_storage" do
    it "creates a namespaced Redis client" do
      storage = subject.namespaced_storage(:foo)
      expect(storage.namespace).to eq(:foo)
    end
  end
end
