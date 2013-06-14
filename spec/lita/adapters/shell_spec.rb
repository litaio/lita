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
      expect(robot).to receive(:receive).with(an_instance_of(Lita::Message))
      subject.run
    end
  end

  describe "#send_message" do
    let(:message) { double("Message") }
    let(:source) { double("Source") }

    it "prints its input" do
      expect(subject).to receive(:puts).with("bar")
      subject.send_message(source, nil, "bar")
    end
  end
end
