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
