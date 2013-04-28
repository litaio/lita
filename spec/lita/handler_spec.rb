require "spec_helper"

describe Lita::Handler do
  let(:handler_class) do
    Class.new(described_class) { def foo; end }
  end

  describe ".listener" do
    it "adds a listener to the registry" do
      handler_class.listener(:foo, /foo/)
      expect(handler_class.listeners).to eq([{ method: :foo, pattern: /foo/ }])
    end
  end

  describe ".dispatch" do
    let(:robot) { double("robot") }
    let(:message) { double("message") }
    let(:handler) { double("handler") }

    before do
      handler_class.listener(:foo, /foo/)
      message.stub(:body) { "foo" }
    end

    it "calls every matching listener for a given message" do
      handler_class.should_receive(:new) { handler }
      handler.should_receive(:foo)
      handler_class.dispatch(robot, message)
    end
  end
end
