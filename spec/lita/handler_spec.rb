require "spec_helper"

describe Lita::Handler do
  let(:handler_class) do
    Class.new(described_class) { def foo; end; def bar; end }
  end

  describe ".listener" do
    it "adds a listener to the registry" do
      handler_class.listener(:foo, /foo/)
      expect(handler_class.listeners).to eq([{ method: :foo, pattern: /foo/ }])
    end
  end

  describe ".command" do
    it "adds a command to the registry" do
      handler_class.command(:bar, "bar")
      expect(handler_class.commands).to eq([{ method: :bar, pattern: "bar" }])
    end
  end

  describe ".dispatch" do
    let(:robot) { double("robot") }
    let(:message) { double("message") }
    let(:handler) { double("handler") }

    before do
      robot.stub(:name) { "Lita" }
      handler_class.command(:bar, "bar")
      handler_class.listener(:foo, /foo/)
    end

    it "calls every matching listener for a given message" do
      message.stub(:parse_command) { nil }
      message.stub(:body) { "foo baz" }
      handler_class.should_receive(:new) { handler }
      handler.should_receive(:foo)
      handler_class.dispatch(robot, message)
    end

    it "calls every matching command for a given message" do
      message.stub(:parse_command) { ["foo", "baz"] }
      message.stub(:body) { "Lita: bar baz" }
      handler_class.should_receive(:new) { handler }
      handler.should_receive(:bar)
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
