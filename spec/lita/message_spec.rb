require "spec_helper"

describe Lita::Message do
  let(:mention_name) { "LitaBot" }

  let(:robot) do
    instance_double("Lita::Robot", name: "Lita", mention_name: mention_name, alias: ".")
  end

  let(:source) { instance_double("Lita::Source") }

  subject do
    described_class.new(robot, "Hello", source)
  end

  it "has a body" do
    expect(subject.body).to eq("Hello")
  end

  it "has a source" do
    expect(subject.source).to eq(source)
  end

  describe "#extensions" do
    it "can be populated with arbitrary data" do
      subject.extensions[:foo] = :bar

      expect(subject.extensions[:foo]).to eq(:bar)
    end
  end

  describe "#args" do
    it "returns an array of the 2nd through nth word in the message" do
      subject = described_class.new(robot, "args foo bar", source)
      expect(subject.args).to eq(%w(foo bar))
    end

    it "escapes messages that have mismatched quotes" do
      subject = described_class.new(robot, "args it's working", source)
      expect(subject.args).to eq(%w(it's working))
    end
  end

  describe "#command!" do
    it "marks a message as a command" do
      subject.command!
      expect(subject).to be_a_command
    end
  end

  describe "#command?" do
    context "when the message is addressed to the robot" do
      subject { described_class.new(robot, "#{robot.mention_name}: hello", source) }

      it "is true" do
        expect(subject).to be_a_command
      end
    end

    context "when the message is addressed to the robot with different capitalization" do
      subject { described_class.new(robot, "#{robot.mention_name.upcase}: hello", source) }

      it "is true" do
        expect(subject).to be_a_command
      end
    end

    context "when the message is addressed to the robot with a comma" do
      subject { described_class.new(robot, "#{robot.mention_name.upcase}, hello", source) }

      it "is true" do
        expect(subject).to be_a_command
      end
    end

    context "when the message is addressed to the robot with no trailing punctuation" do
      subject { described_class.new(robot, "#{robot.mention_name.upcase} hello", source) }

      it "is true" do
        expect(subject).to be_a_command
      end
    end

    context "when the message is addressed to the bot via alias with no space after it" do
      subject { described_class.new(robot, "#{robot.alias}hello", source) }

      it "is true" do
        expect(subject).to be_a_command
      end
    end

    context "when the message is addressed to the bot via alias with space after it" do
      subject { described_class.new(robot, "#{robot.alias} hello", source) }

      it "is true" do
        expect(subject).to be_a_command
      end
    end

    context "when the message incidentally starts with the mention name" do
      let(:mention_name) { "sa" }

      subject { described_class.new(robot, "salmon", source) }

      it "is false" do
        expect(subject).not_to be_a_command
      end

      it "does not affect the message body" do
        expect(subject.body).to eq("salmon")
      end
    end

    context "when a multi-line message contains a command past the beginning of the message" do
      subject { described_class.new(robot, "```\n#{robot.mention_name}: hello\n```", source) }

      it "is false" do
        expect(subject).not_to be_a_command
      end
    end

    it "is false when the message is not addressed to the Robot" do
      expect(subject).not_to be_a_command
    end
  end

  describe "#user" do
    it "delegates to #source" do
      expect(subject.source).to receive(:user)
      subject.user
    end
  end

  describe "#room_object" do
    it "delegates to #source" do
      expect(subject.source).to receive(:room_object)
      subject.room_object
    end
  end

  describe "#private_message?" do
    it "delegates to #source" do
      expect(subject.source).to receive(:private_message?)
      subject.private_message?
    end
  end

  describe "#reply" do
    it "sends strings back to the source through the robot" do
      expect(robot).to receive(:send_messages).with(source, "foo", "bar")
      subject.reply("foo", "bar")
    end
  end

  describe "#reply_privately" do
    it "sends strings directly to the source user" do
      subject = described_class.new(
        robot,
        "Hello",
        Lita::Source.new(user: "Carl", room: "#room")
      )
      expect(robot).to receive(:send_messages) do |source, *strings|
        expect(source).to be_a_private_message
        expect(strings).to eq(%w(foo bar))
      end
      subject.reply_privately("foo", "bar")
    end
  end

  describe "#reply_with_mention" do
    it "prefixes strings with a user mention and sends them back to the source" do
      expect(robot).to receive(:send_messages_with_mention).with(source, "foo", "bar")
      subject.reply_with_mention("foo", "bar")
    end
  end
end
