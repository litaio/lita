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
end

handler_class = Class.new(Lita::Handler) do
  def self.name
    "Lita::Handlers::Test"
  end

  route(/\w{3}/, to: :foo)
  route(/\w{4}/, to: :blah, command: true)
  route(/args/, to: :test_args)

  def foo(matches)
  end

  def blah(matches)
  end

  def test_args(matches)
    say args
  end
end

describe handler_class do
  let(:robot) do
    robot = double("Robot")
    allow(robot).to receive(:name).and_return("Lita")
    robot
  end

  before { allow(Lita).to receive(:handlers).and_return([described_class]) }

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
      expect(robot).to receive(:say).with(["foo", "bar"])
      described_class.dispatch(robot, "args foo bar")
    end

    it "escapes messages that have mismatched quotes" do
      expect(robot).to receive(:say).with(["it's", "working"])
      described_class.dispatch(robot, "args it's working")
    end
  end
end
