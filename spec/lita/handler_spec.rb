require "spec_helper"

describe Lita::Handler do
  let(:robot) do
    robot = double("Robot")
    allow(robot).to receive(:name).and_return("Lita")
    robot
  end

  describe "#command?" do
    it "is true when the message is addressed to the Robot" do
      subject = described_class.new(robot, "#{robot.name}: hello")
      expect(subject).to be_a_command
    end

    it "is false when the message is not addressed to the Robot" do
      subject = described_class.new(robot, "hello")
      expect(subject).not_to be_a_command
    end
  end

  describe "say" do
    it "calls Robot#say with the original message and messages to send" do
      subject = described_class.new(robot, "hello")
      expect(robot).to receive(:say).with("hello", "foo")
      subject.say("foo")
    end
  end
end

describe Lita::Handlers::Test, lita_handler: true do
  let(:robot) { Lita::Robot.new }

  before { allow(Lita).to receive(:handlers).and_return([described_class]) }

  describe "RSpec extras" do
    it { routes("foo").to(:foo) }
  end

  describe ".dispatch" do
    it "routes a matching message to the supplied method" do
      expect_any_instance_of(described_class).to receive(:foo)
      described_class.dispatch(robot, "foo")
    end

    it "routes a matching message even if addressed to the Robot" do
      expect_any_instance_of(described_class).to receive(:foo)
      described_class.dispatch(robot, "#{robot.name}: foo")
    end

    it "routes a command message to the supplied method" do
      expect_any_instance_of(described_class).to receive(:blah)
      described_class.dispatch(robot, "#{robot.name}: blah")
    end

    it "requires command routes to be addressed to the Robot" do
      expect_any_instance_of(described_class).not_to receive(:blah)
      described_class.dispatch(robot, "blah")
    end
  end

  describe "#args" do
    it "returns an array of the 2nd through nth word in the message" do
      expect(robot).to receive(:say).with("args foo bar", ["foo", "bar"])
      described_class.dispatch(robot, "args foo bar")
    end

    it "escapes messages that have mismatched quotes" do
      expect(robot).to receive(:say).with(
        "args it's working", ["it's", "working"]
      )
      described_class.dispatch(robot, "args it's working")
    end
  end
end
