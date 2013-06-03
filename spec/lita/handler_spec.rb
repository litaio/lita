require "spec_helper"

describe Lita::Handler do
  let(:handler_class) do
    Class.new(described_class) { def foo(m); end; def bar(m); end }
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

    before do
      robot.stub(:name) { "Lita" }
      handler_class.listener(:foo, /foo/)
      handler_class.command(:bar, "bar")
      message.stub(:command_with_args).and_return(true)
    end

    it "calls every matching listener for a given message" do
      message.stub(:matches).and_return([["foo"]])
      handler_class.any_instance.should_receive(:foo).with(message)
      handler_class.dispatch(robot, message)
    end

    it "calls every matching command for a given message" do
      message.stub(:matches).and_return([["bar"]])
      handler_class.any_instance.should_receive(:bar).with(message)
      handler_class.dispatch(robot, message)
    end
  end

  describe "namespaced storage" do
    let(:robot) { double("robot") }

    before { handler_class.send(:define_method, :get_storage) { storage } }

    it "raises an exception when calling #storage without a storage key" do
      handler = handler_class.new(robot)
      expect { handler.get_storage }.to raise_error(Lita::MissingStorageKeyError)
    end

    it "namespaces storage with a storage key from the class name" do
      handler_class.singleton_class.send(:define_method, :name) do
        "Lita::Handlers::MyHandler"
      end
      handler = handler_class.new(robot)
      robot.should_receive(:storage_for_handler).with("myhandler")
      handler.get_storage
    end

    it "namespaces storage with a manually specified storage key" do
      handler_class.send(:define_method, :storage_key) { :my_handler }
      handler = handler_class.new(robot)
      robot.should_receive(:storage_for_handler).with(:my_handler)
      handler.get_storage
    end
  end
end
