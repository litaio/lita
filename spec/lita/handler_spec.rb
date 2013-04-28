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

  describe "namespaced storage" do
    let(:robot) { double("robot") }

    before { handler_class.define_method(:get_storage) { storage } }

    it "raises an exception when calling #storage without a storage key" do
      handler = handler_class.new(stub, stub, stub)
      expect { handler.get_storage }.to raise_error(Lita::MissingStorageKeyError)
    end

    it "namespaces storage with a storage key from the class name" do
      handler_class.singleton_class.define_method(:name) do
        "Lita::Handlers::MyHandler"
      end
      handler = handler_class.new(robot, stub, stub)
      robot.should_receive(:storage_for_handler).with("myhandler")
      handler.get_storage
    end

    it "namespaces storage with a manually specified storage key" do
      handler_class.define_method(:storage_key) { :my_handler }
      handler = handler_class.new(robot, stub, stub)
      robot.should_receive(:storage_for_handler).with(:my_handler)
      handler.get_storage
    end
  end
end
