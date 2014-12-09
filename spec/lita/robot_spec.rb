require "spec_helper"

describe Lita::Robot, lita: true do
  subject { described_class.new(registry) }

  before { registry.register_adapter(:shell, Lita::Adapters::Shell) }

  it "triggers a loaded event after initialization" do
    expect_any_instance_of(described_class).to receive(:trigger).with(:loaded)
    subject
  end

  it "can have its name changed" do
    subject.name = "Bongo"

    expect(subject.name).to eq("Bongo")
  end

  it "can have its mention name changed" do
    subject.mention_name = "wongo"

    expect(subject.mention_name).to eq("wongo")
  end

  context "with registered handlers" do
    let(:handler1) { Class.new(Lita::Handler) { namespace :test } }
    let(:handler2) { Class.new(Lita::Handler) { namespace :test } }

    before do
      registry.register_handler(handler1)
      registry.register_handler(handler2)
    end

    describe "#receive" do
      it "dispatches messages to every registered handler" do
        expect(handler1).to receive(:dispatch).with(subject, "foo")
        expect(handler2).to receive(:dispatch).with(subject, "foo")
        subject.receive("foo")
      end
    end

    describe "#trigger" do
      it "triggers the supplied event on all registered handlers" do
        expect(handler1).to receive(:trigger).with(subject, :foo, bar: "baz")
        expect(handler2).to receive(:trigger).with(subject, :foo, bar: "baz")
        subject.trigger(:foo, bar: "baz")
      end
    end
  end

  describe "#run" do
    let(:thread) { instance_double("Thread", :abort_on_exception= => true, join: nil) }

    before do
      allow_any_instance_of(Lita::Adapters::Shell).to receive(:run)
      allow_any_instance_of(Puma::Server).to receive(:run)
      allow_any_instance_of(Puma::Server).to receive(:add_tcp_listener)

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
      expect_any_instance_of(Puma::Server).to receive(:run)
      subject.run
    end

    it "rescues interrupts and calls #shut_down" do
      allow_any_instance_of(
        Lita::Adapters::Shell
      ).to receive(:run).and_raise(Interrupt)
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:shut_down)
      subject.run
    end

    it "logs and quits if the specified adapter can't be found" do
      registry.config.robot.adapter = :does_not_exist
      expect(Lita.logger).to receive(:fatal).with(/Unknown adapter/)
      expect { subject.run }.to raise_error(SystemExit)
    end

    it "logs and aborts if the web server's port is in use" do
      allow_any_instance_of(Puma::Server).to receive(:add_tcp_listener).and_raise(Errno::EADDRINUSE)

      expect(Lita.logger).to receive(:fatal).with(/web server/)
      expect { subject.run }.to raise_error(SystemExit)
    end

    it "logs and aborts if the web server's port is privileged" do
      allow_any_instance_of(Puma::Server).to receive(:add_tcp_listener).and_raise(Errno::EACCES)

      expect(Lita.logger).to receive(:fatal).with(/web server/)
      expect { subject.run }.to raise_error(SystemExit)
    end
  end

  describe "#join" do
    it "delegates to the adapter" do
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:join).with("#lita.io")
      subject.join("#lita.io")
    end
  end

  describe "#part" do
    it "delegates to the adapter" do
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:part).with("#lita.io")
      subject.part("#lita.io")
    end
  end

  describe "#send_message" do
    let(:source) { instance_double("Lita::Source") }

    it "delegates to the adapter" do
      expect_any_instance_of(
        Lita::Adapters::Shell
      ).to receive(:send_messages).with(
        source, %w(foo bar)
      )
      subject.send_messages(source, "foo", "bar")
    end
  end

  describe "#send_message_with_mention" do
    let(:user) { instance_double("Lita::User", mention_name: "carl") }
    let(:source) { instance_double("Lita::Source", private_message?: false, user: user) }

    it "calls #send_message with the strings, prefixed with the user's mention name" do
      allow_any_instance_of(Lita::Adapters::Shell).to receive(:mention_format).with(
        "carl"
      ).and_return("carl:")
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:send_messages).with(
        source,
        ["carl: foo", "carl: bar"]
      )

      subject.send_messages_with_mention(source, "foo", "bar")
    end

    it "strips whitespace from both sides of the formatted mention name" do
      allow_any_instance_of(Lita::Adapters::Shell).to receive(:mention_format).with(
        "carl"
      ).and_return("   carl:   ")
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:send_messages).with(
        source,
        ["carl: foo", "carl: bar"]
      )

      subject.send_messages_with_mention(source, "foo", "bar")
    end

    it "calls #send_message directly if the original message was sent privately" do
      allow(source).to receive(:private_message?).and_return(true)
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:send_messages).with(
        source,
        %w(foo bar)
      )

      subject.send_messages_with_mention(source, "foo", "bar")
    end
  end

  describe "#set_topic" do
    let(:source) { instance_double("Lita::Source") }

    it "delegates to the adapter" do
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:set_topic).with(
        source,
        "New topic"
      )
      subject.set_topic(source, "New topic")
    end
  end

  describe "#shut_down" do
    before { allow_any_instance_of(Lita::Adapters::Shell).to receive(:puts) }

    it "gracefully stops the adapter" do
      expect_any_instance_of(Lita::Adapters::Shell).to receive(:shut_down)
      subject.shut_down
    end

    it "triggers events for shut_down_started and shut_down_complete" do
      expect(subject).to receive(:trigger).with(:shut_down_started).ordered
      expect(subject).to receive(:trigger).with(:shut_down_complete).ordered
      subject.shut_down
    end
  end
end
