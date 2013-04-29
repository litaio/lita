require "spec_helper"

describe Lita::Adapters::Shell do
  subject do
    described_class.new(robot, config, stdout: stdout, stdin: stdin)
  end

  let(:robot) { double("robot") }
  let(:config) { double("config") }
  let(:stdout) { StringIO.new }
  let(:stdin) { StringIO.new }

  before { robot.stub(:name) { "Lita" } }

  describe "#run" do
    let!(:thread) { Thread.new { subject.run } }

    # Removing this before hook causes the examples to fail intermittently
    before { sleep 0.001 }
    after { thread.kill if thread.alive? }

    it "prints a message on how to end the session" do
      expect(stdout.string).to match(/end the session/)
    end

    it "prints a prompt for user input" do
      expect(stdout.string).to match(/Lita > /)
    end

    it "exits when the input is exit" do
      stdin.puts("exit")
      stdin.rewind
      expect(thread).not_to be_alive
    end

  end

  describe "#say" do
    it "writes messages to stdout" do
      stdout.should_receive(:puts).with("foo")
      stdout.should_receive(:puts).with("bar")
      subject.say("foo", "bar")
    end
  end
end
