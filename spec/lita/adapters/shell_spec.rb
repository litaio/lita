describe Lita::Adapters::Shell do
  let(:robot) { double("Lita::Robot", name: "Lita", mention_name: "LitaBot") }

  subject { described_class.new(robot) }

  describe "#run" do
    before do
      allow(subject).to receive(:puts)
      allow(subject).to receive(:print)
      allow($stdin).to receive(:gets).and_return("foo", "exit")
      allow(robot).to receive(:receive)
    end

    it "passes input to the Robot and breaks on an exit message" do
      expect(subject).to receive(:print).with("#{robot.name} > ").twice
      expect(robot).to receive(:receive).with(an_instance_of(Lita::Message))
      subject.run
    end

    it "marks messages as commands if config.adapter.private_chat is true" do
      Lita.config.adapter.private_chat = true
      expect_any_instance_of(Lita::Message).to receive(:command!)
      subject.run
    end
  end

  describe "#send_message" do
    it "prints its input" do
      expect(subject).to receive(:puts).with("bar")
      subject.send_messages(double("target"), "bar")
    end
  end

  describe "#shut_down" do
    it "outputs a blank line" do
      expect(subject).to receive(:puts)
      subject.shut_down
    end
  end
end
