require "spec_helper"

describe Lita::Handler do
  let(:robot) do
    robot = double("Robot")
    allow(robot).to receive(:name).and_return("Lita")
    robot
  end

  let(:message) { double("Message") }

  subject { described_class.new(robot, message) }

  describe "#args" do
    it "delegates to Message" do
      expect(message).to receive(:args)
      subject.args
    end
  end

  describe "#command?" do
    it "delegates to Message" do
      expect(message).to receive(:command?)
      subject.command?
    end
  end

  describe "#say" do
    it "calls Robot#say with the original message and messages to send" do
      expect(robot).to receive(:say).with(message, "foo")
      subject.say("foo")
    end
  end

  describe "#scan" do
    it "delegates to Message" do
      expect(message).to receive(:scan)
      subject.scan
    end
  end
end

describe Lita::Handlers::Test, lita_handler: true do
  let(:robot) do
    robot = double("Robot")
    allow(robot).to receive(:name).and_return("Lita")
    robot
  end

  let(:message) do
    message = double("Message")
    allow(message).to receive(:scan)
    allow(message).to receive(:command?).and_return(false)
    message
  end

  before { allow(Lita).to receive(:handlers).and_return([described_class]) }

  describe "RSpec extras" do
    xit { routes("foo").to(:foo) }
  end

  describe ".dispatch" do
    it "routes a matching message to the supplied method" do
      allow(message).to receive(:body).and_return("bar")
      expect_any_instance_of(described_class).to receive(:foo)
      described_class.dispatch(robot, message)
    end

    it "routes a matching message even if addressed to the Robot" do
      allow(message).to receive(:body).and_return("#{robot.name}: bar")
      allow(message).to receive(:command?).and_return(true)
      expect_any_instance_of(described_class).to receive(:foo)
      described_class.dispatch(robot, message)
    end

    it "routes a command message to the supplied method" do
      allow(message).to receive(:body).and_return("#{robot.name}: bar")
      allow(message).to receive(:command?).and_return(true)
      expect_any_instance_of(described_class).to receive(:blah)
      described_class.dispatch(robot, message)
    end

    it "requires command routes to be addressed to the Robot" do
      allow(message).to receive(:body).and_return("blah")
      expect_any_instance_of(described_class).not_to receive(:blah)
      described_class.dispatch(robot, message)
    end
  end
end
