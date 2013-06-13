describe Lita::Adapters::Shell do
  let(:robot) do
    robot = double("Robot")
    allow(robot).to receive(:name).and_return("Lita")
    robot
  end

  subject { described_class.new(robot) }

  describe "#run" do
    it "passes input to the Robot and breaks on an exit message" do
      expect(subject).to receive(:print).with("#{robot.name} > ").twice
      allow(subject).to receive(:gets).and_return("foo", "exit")
      expect(robot).to receive(:receive).with("foo")
      subject.run
    end
  end

  describe "#say" do
    let(:message) { double("Message") }

    it "prints its input" do
      expect(subject).to receive(:puts).with("bar")
      subject.say(message, "bar")
    end
  end
end
