require "spec_helper"

describe Lita::Robot do
  it "logs and quits if the specified adapter can't be found" do
    adapter_registry = double("adapter_registry")
    allow(Lita).to receive(:adapters).and_return(adapter_registry)
    allow(adapter_registry).to receive(:[]).and_return(nil)
    expect(Lita.logger).to receive(:fatal).with(/Unknown adapter/)
    expect { subject }.to raise_error(SystemExit)
  end

  it "triggers a loaded event after initialization" do
    expect_any_instance_of(described_class).to receive(:trigger).with(:loaded)
    subject
  end

  context "with registered handlers" do
    let(:handler1) { class_double("Lita::Handler", http_routes: [], trigger: nil) }
    let(:handler2) { class_double("Lita::Handler", http_routes: [], trigger: nil) }

    before do
      allow(Lita).to receive(:handlers).and_return([handler1, handler2])
    end

    describe "#receive" do
      context "for messages that are supported by at least one handler" do
        it "dispatches a message to every registered handler that supports it" do
          allow(handler1).to receive(:supports_message?).with(subject, "foo").and_return(true)
          allow(handler2).to receive(:supports_message?).with(subject, "foo").and_return(true)

          expect(handler1).to receive(:dispatch).with(subject, "foo")
          expect(handler2).to receive(:dispatch).with(subject, "foo")

          subject.receive("foo")
        end

        it "does not dispatch a message to handlers that do not support it" do
          allow(handler1).to receive(:supports_message?).with(subject, "bar").and_return(true)
          allow(handler2).to receive(:supports_message?).with(subject, "bar").and_return(false)

          expect(handler1).to receive(:dispatch).with(subject, "bar")
          expect(handler2).to_not receive(:dispatch)

          subject.receive("bar")
        end

        it "should not call the received_unsupported_message method" do
          allow(handler1).to receive(:supports_message?).with(subject, "baz").and_return(true)
          allow(handler2).to receive(:supports_message?).with(subject, "baz").and_return(false)

          expect(handler1).to receive(:dispatch).with(subject, "baz")
          expect(subject).to_not receive(:received_unsupported_message)

          subject.receive("baz")
        end
      end

      context "for messages that are not supported by any handlers" do
        let(:message) { instance_double("Lita::Message") }

        before do
          allow(handler1).to receive(:supports_message?).with(subject, anything).and_return(false)
          allow(handler2).to receive(:supports_message?).with(subject, anything).and_return(false)
        end

        context "when config.robot.handle_unsupported_messages = false" do
          before do
            Lita.config.robot.handle_unsupported_messages = false
          end

          it "should not respond" do
            expect(message).to_not receive(:reply_with_mention)
            subject.receive(message)
          end
        end

        context "when config.robot.handle_unsupported_messages = true" do
          before do
            Lita.config.robot.handle_unsupported_messages = true
          end

          it "should respond with mention if the message is a command" do
            allow(message).to receive(:command?).and_return(true)

            unsupported_message = I18n.t("lita.robot.unsupported_message")
            expect(message).to receive(:reply_with_mention).with(unsupported_message)

            subject.receive(message)
          end

          it "should not respond if the message is not a command" do
            allow(message).to receive(:command?).and_return(false)
            expect(message).to_not receive(:reply_with_mention)
            subject.receive(message)
          end
        end
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
