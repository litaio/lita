require "spec_helper"

describe Lita::Robot do
  it "raises an exception if the specified adapter can't be found" do
    adapter_registry = double("adapter_registry")
    allow(Lita).to receive(:adapters).and_return(adapter_registry)
    allow(adapter_registry).to receive(:[]).and_return(nil)
    expect { subject }.to raise_error(Lita::UnknownAdapterError)
  end

  describe "#receive" do
    let(:handler1) { double("Handler 1") }
    let(:handler2) { double("Handler 2") }

    it "dispatches messages to every registered handler" do
      allow(Lita).to receive(:handlers).and_return([handler1, handler2])
      expect(handler1).to receive(:dispatch).with(subject, "foo")
      expect(handler2).to receive(:dispatch).with(subject, "foo")
      subject.receive("foo")
    end
  end

  describe "#run" do
    it "starts the adapter" do
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:run)
      subject.run
    end

    it "rescues interrupts and calls #shut_down" do
      allow_any_instance_of(
        Lita::Adapters::Shell
      ).to receive(:run).and_raise(Interrupt)
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:shut_down)
      subject.run
    end
  end

  describe "#send_message" do
    let(:message) { double("Message") }

    it "delegates to the adapter" do
      expect_any_instance_of(
        Lita::Adapters::Shell
      ).to receive(:send_messages).with(
        message, ["foo", "bar"]
      )
      subject.send_messages(message, "foo", "bar")
    end
  end

  describe "#shut_down" do
    it "gracefully stops the adapter" do
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:shut_down)
      subject.shut_down
    end
  end
end
