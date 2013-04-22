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
end
