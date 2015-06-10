require "spec_helper"

describe Lita::Adapters::Shell, lita: true do
  let(:robot) do
    instance_double(
      "Lita::Robot",
      name: "Lita",
      mention_name: "LitaBot",
      alias: "/",
      config: registry.config
    )
  end

  subject { described_class.new(robot) }

  describe "#roster" do
    let(:room) { instance_double("Lita::Room") }

    it "returns the shell user" do
      expect(subject.roster(room).first.name).to eq("Shell User")
    end
  end

  describe "#run" do
    let(:user) { Lita::User.create(1, name: "Shell User") }

    before do
      registry.register_adapter(:shell, described_class)
      allow(subject).to receive(:puts)
      allow(Readline).to receive(:readline).and_return("foo", "exit")
      allow(robot).to receive(:trigger)
      allow(robot).to receive(:receive)
      allow(Lita::User).to receive(:create).and_return(user)
    end

    it "passes input to the Robot and breaks on an exit message" do
      expect(Readline).to receive(:readline).with("#{robot.name} > ", true).twice
      expect(robot).to receive(:receive).with(an_instance_of(Lita::Message))
      subject.run
    end

    it "marks messages as commands if config.adapters.shell.private_chat is true" do
      registry.config.adapters.shell.private_chat = true
      expect_any_instance_of(Lita::Message).to receive(:command!)
      subject.run
    end

    it "sets the room to 'shell' if config.adapters.shell.private_chat is false" do
      registry.config.adapters.shell.private_chat = false
      expect(Lita::Source).to receive(:new).with(user: user, room: "shell")
      subject.run
    end

    it "sets the room to nil if config.adapters.shell.private_chat is true" do
      registry.config.adapters.shell.private_chat = true
      expect(Lita::Source).to receive(:new).with(user: user, room: nil)
      subject.run
    end

    it "triggers a connected event" do
      expect(robot).to receive(:trigger).with(:connected)
      subject.run
    end

    it "exits cleanly when EOF is received" do
      allow(Readline).to receive(:readline).and_return(nil)
      subject.run
    end

    it "removes empty input from readline history" do
      allow(Readline).to receive(:readline).and_return("", "exit")
      expect(Readline::HISTORY).to receive(:pop)
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
