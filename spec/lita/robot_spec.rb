# frozen_string_literal: true

require "spec_helper"

describe Lita::Robot, lita: true do
  subject { described_class.new(registry) }

  before { registry.register_adapter(:shell, Lita::Adapters::Shell) }

  it "triggers a loaded event after initialization" do
    expect_any_instance_of(described_class).to receive(:trigger).with(:loaded, room_ids: [])
    subject
  end

  context "when there are previously persisted rooms" do
    before { %w[#foo #bar].each { |id| Lita.redis.sadd("persisted_rooms", id) } }

    it "receives the room_ids in the payload" do
      expect_any_instance_of(described_class).to receive(:trigger).with(
        :loaded,
        room_ids: %w[#foo #bar].sort,
      )
      subject
    end
  end

  it "can have its name changed" do
    subject.name = "Bongo"

    expect(subject.name).to eq("Bongo")
  end

  it "can have its mention name changed" do
    subject.mention_name = "wongo"

    expect(subject.mention_name).to eq("wongo")
  end

  it "exposes Adapter#mention_format" do
    expect(subject.mention_format(subject.mention_name)).to eq("Lita:")
  end

  it "exposes Adapter#roster" do
    expect_any_instance_of(Lita::Adapters::Shell).to receive(:roster)

    subject.roster(instance_double("Lita::Room"))
  end

  it "exposes Adapter#chat_service" do
    expect { subject.chat_service }.not_to raise_error
  end

  context "with registered handlers" do
    let(:handler_1) { Class.new(Lita::Handler) { namespace :test } }
    let(:handler_2) { Class.new(Lita::Handler) { namespace :test } }

    before do
      registry.register_handler(handler_1)
      registry.register_handler(handler_2)
    end

    describe "#receive" do
      it "dispatches messages to every registered handler" do
        expect(handler_1).to receive(:dispatch).with(subject, "foo")
        expect(handler_2).to receive(:dispatch).with(subject, "foo")
        subject.receive("foo")
      end
    end

    describe "#trigger" do
      it "triggers the supplied event on all registered handlers" do
        expect(handler_1).to receive(:trigger).with(subject, :foo, bar: "baz")
        expect(handler_2).to receive(:trigger).with(subject, :foo, bar: "baz")
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
      expect(subject.logger).to receive(:fatal).with(/Unknown adapter/)
      expect { subject.run }.to raise_error(SystemExit)
    end

    it "logs and aborts if the web server's port is in use" do
      allow_any_instance_of(Puma::Server).to receive(:add_tcp_listener).and_raise(Errno::EADDRINUSE)

      expect(subject.logger).to receive(:fatal).with(/web server/)
      expect { subject.run }.to raise_error(SystemExit)
    end

    it "logs and aborts if the web server's port is privileged" do
      allow_any_instance_of(Puma::Server).to receive(:add_tcp_listener).and_raise(Errno::EACCES)

      expect(subject.logger).to receive(:fatal).with(/web server/)
      expect { subject.run }.to raise_error(SystemExit)
    end
  end

  describe "#join" do
    before do
      allow_any_instance_of(Lita::Adapters::Shell).to receive(:join)
    end

    context "when a Room object exists" do
      let!(:room) { Lita::Room.create_or_update(1, name: "#lita.io") }

      it "passes the room ID to the adapter when a string argument is provided" do
        expect_any_instance_of(Lita::Adapters::Shell).to receive(:join).with("1")

        subject.join("#lita.io")
      end

      it "passes the room ID to the adapter when a Room argument is provided" do
        expect_any_instance_of(Lita::Adapters::Shell).to receive(:join).with("1")

        subject.join(room)
      end

      it "adds the room ID to the persisted list" do
        subject.join("#lita.io")

        expect(subject.persisted_rooms).to include("1")
      end
    end

    context "when no Room object exists" do
      it "delegates to the adapter with the raw argument" do
        expect_any_instance_of(Lita::Adapters::Shell).to receive(:join).with("#lita.io")

        subject.join("#lita.io")
      end
    end
  end

  describe "#part" do
    before do
      allow_any_instance_of(Lita::Adapters::Shell).to receive(:join)
      allow_any_instance_of(Lita::Adapters::Shell).to receive(:part)
    end

    context "when a Room object exists" do
      let!(:room) { Lita::Room.create_or_update(1, name: "#lita.io") }

      it "passes the room ID to the adapter when a string argument is provided" do
        expect_any_instance_of(Lita::Adapters::Shell).to receive(:part).with("1")

        subject.part("#lita.io")
      end

      it "passes the room ID to the adapter when a Room argument is provided" do
        expect_any_instance_of(Lita::Adapters::Shell).to receive(:part).with("1")

        subject.part(room)
      end

      it "removes the room ID from the persisted list" do
        subject.join("#lita.io")

        subject.part("#lita.io")

        expect(subject.persisted_rooms).not_to include("1")
      end
    end

    context "when no Room object exists" do
      it "delegates to the adapter with the raw argument" do
        expect_any_instance_of(Lita::Adapters::Shell).to receive(:part).with("#lita.io")

        subject.part("#lita.io")
      end
    end
  end

  describe "#send_message" do
    let(:source) { instance_double("Lita::Source") }

    it "delegates to the adapter" do
      expect_any_instance_of(
        Lita::Adapters::Shell
      ).to receive(:send_messages).with(
        source, %w[foo bar]
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
        %w[foo bar]
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
