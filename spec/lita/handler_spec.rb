require "spec_helper"

describe Lita::Handler do
  let(:robot) do
    robot = double("Robot")
    allow(robot).to receive(:name).and_return("Lita")
    robot
  end

  let(:message) do
    message = double("Message")
    allow(message).to receive(:scan).and_return(matches)
    allow(message).to receive(:command?).and_return(false)
    message
  end

  let(:matches) { double("MatchData") }

  let(:handler_class) do
    Class.new(described_class) do
      route(/\w{3}/, to: :foo)
      route(/\w{4}/, to: :blah, command: true)

      def foo(matches)
      end

      def blah(matches)
      end

      def self.name
        "Lita::Handlers::Test"
      end
    end
  end

  subject { described_class.new(robot, message) }

  describe ".dispatch" do
    it "routes a matching message to the supplied method" do
      allow(message).to receive(:body).and_return("bar")
      expect_any_instance_of(handler_class).to receive(:foo)
      handler_class.dispatch(robot, message)
    end

    it "routes a matching message even if addressed to the Robot" do
      allow(message).to receive(:body).and_return("#{robot.name}: bar")
      allow(message).to receive(:command?).and_return(true)
      expect_any_instance_of(handler_class).to receive(:foo)
      handler_class.dispatch(robot, message)
    end

    it "routes a command message to the supplied method" do
      allow(message).to receive(:body).and_return("#{robot.name}: bar")
      allow(message).to receive(:command?).and_return(true)
      expect_any_instance_of(handler_class).to receive(:blah)
      handler_class.dispatch(robot, message)
    end

    it "requires command routes to be addressed to the Robot" do
      allow(message).to receive(:body).and_return("blah")
      expect_any_instance_of(handler_class).not_to receive(:blah)
      handler_class.dispatch(robot, message)
    end

    it "doesn't route messages that don't match anything" do
      allow(message).to receive(:body).and_return("yo")
      expect_any_instance_of(handler_class).not_to receive(:foo)
      expect_any_instance_of(handler_class).not_to receive(:blah)
      handler_class.dispatch(robot, message)
    end
  end

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

  describe "#message_body" do
    it "delegates to Message" do
      expect(message).to receive(:body)
      subject.message_body
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
