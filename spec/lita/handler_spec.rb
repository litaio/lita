require "spec_helper"

describe Lita::Handler do
  let(:handler_class) do
    Class.new(described_class) do
      match /foo/
    end
  end

  let(:message) do
    message = double("message")
    message.stub(:body) { "foo" }
    message
  end

  let(:unmatching_message) do
    message = double("message")
    message.stub(:body) { "bar" }
    message
  end

  describe ".match" do
    it "stores the string or pattern the message must match" do
      expect(handler_class.match).to eq(/foo/)
    end
  end

  describe ".match?" do
    it "returns true if the message matches the pattern" do
      expect(handler_class.match?(message)).to be_true
    end

    it "returns false if the message doesn't match the pattern" do
      expect(handler_class.match?(unmatching_message)).to be_false
    end
  end

  describe ".description" do
    it "sets and gets a description string" do
      expect(handler_class.description).to be_false
      handler_class.description "a description"
      expect(handler_class.description).to eq("a description")
    end
  end

  describe ".storage_key" do
    it "sets and gets the key used to namespace the handler's storage" do
      expect(handler_class.storage_key).to be_false
      handler_class.storage_key :isolated_storage
      expect(handler_class.storage_key).to eq(:isolated_storage)
    end
  end
end
