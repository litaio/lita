describe Lita::Adapters::Shell do
  let(:robot) do
    instance_double("Lita::Robot", name: "Lita", mention_name: "LitaBot", alias: "/")
  end

  subject { described_class.new(robot) }

  describe "#run" do
    before do
      allow(subject).to receive(:puts)
      allow(Readline).to receive(:readline).and_return("foo", "exit")
      allow(robot).to receive(:trigger)
      allow(robot).to receive(:receive)
    end

    it "passes input to the Robot and breaks on an exit message" do
      expect(Readline).to receive(:readline).with("#{robot.name} > ", true).twice
      expect(robot).to receive(:receive).with(an_instance_of(Lita::Message))
      subject.run
    end

    it "marks messages as commands if config.adapter.private_chat is true" do
      Lita.config.adapter.private_chat = true
      expect_any_instance_of(Lita::Message).to receive(:command!)
      subject.run
    end

    it "triggers a connected event" do
      expect(robot).to receive(:trigger).with(:connected)
      subject.run
    end
  end

  describe "#send_message" do
    it "prints its input" do
      expect(subject).to receive(:puts) do |messages|
        expect(messages.first).to include("bar")
      end
      subject.send_messages(instance_double("Lita::Source"), "bar")
    end

    it "doesn't output empty messages" do
      expect(subject).to receive(:puts).with([])
      subject.send_messages(instance_double("Lita::Source"), "")
    end
  end

  describe "#shut_down" do
    it "outputs a blank line" do
      expect(subject).to receive(:puts)
      subject.shut_down
    end
  end
end
