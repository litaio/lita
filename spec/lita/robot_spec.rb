require "spec_helper"

describe Lita::Robot do
  it "logs and quits if the specified adapter can't be found" do
    adapter_registry = double("adapter_registry")
    allow(Lita).to receive(:adapters).and_return(adapter_registry)
    allow(adapter_registry).to receive(:[]).and_return(nil)
    expect(Lita.logger).to receive(:fatal).with(/Unknown adapter/)
    expect { subject }.to raise_error(SystemExit)
  end

  describe "#receive" do
    let(:handler1) { double("Handler 1").as_null_object }
    let(:handler2) { double("Handler 2").as_null_object }

    it "dispatches messages to every registered handler" do
      allow(Lita).to receive(:handlers).and_return([handler1, handler2])
      expect(handler1).to receive(:dispatch).with(subject, "foo")
      expect(handler2).to receive(:dispatch).with(subject, "foo")
      subject.receive("foo")
    end
  end

  describe "#run" do
    let(:thread) { double("Thread", :abort_on_exception= => true, join: nil) }

    before do
      allow_any_instance_of(Lita::Adapters::Shell).to receive(:run)
      allow_any_instance_of(Thin::Server).to receive(:start)

      allow(Thread).to receive(:new) do |&block|
        block.call
        thread
      end
    end

    it "starts the adapter" do
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:run)
      subject.run
    end

    it "starts the web server" do
      expect_any_instance_of(Thin::Server).to receive(:start)
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
    let(:source) { double("Source") }

    it "delegates to the adapter" do
      expect_any_instance_of(
        Lita::Adapters::Shell
      ).to receive(:send_messages).with(
        source, ["foo", "bar"]
      )
      subject.send_messages(source, "foo", "bar")
    end
  end

  describe "#set_topic" do
    let(:source) { double("Source") }

    it "delegates to the adapter" do
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:set_topic).with(
        source,
        "New topic"
      )
      subject.set_topic(source, "New topic")
    end
  end

  describe "#shut_down" do
    it "gracefully stops the adapter" do
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:shut_down)
      subject.shut_down
    end
  end
end
