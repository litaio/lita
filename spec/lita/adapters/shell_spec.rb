require "spec_helper"

describe Lita::Adapters::Shell do
  subject do
    described_class.new(robot, config, stdout: stdout, stdin: stdin)
  end

  let(:queue_io) do
    Class.new(Queue) do
      alias_method :print, :push
      alias_method :gets, :pop

      def puts(message)
        print("#{message}\n")
      end
    end
  end

  let(:robot) { double("robot") }
  let(:config) { double("config") }
  let(:stdout) { queue_io.new }
  let(:stdin) { queue_io.new }

  before { robot.stub(:name) { "Lita" } }

  describe "#run" do
    let(:thread) { Thread.new { subject.run } }
    let(:message) { double("message") }

    before { thread }
    after { thread.kill if thread.alive? }

    it "prints a message on how to end the session" do
      expect(stdout.gets).to match(/end the session/)
    end

    it "prints a prompt for user input" do
      stdout.gets # Start up message

      expect(stdout.gets).to match(/Lita > /)
    end

    it "exits when the input is exit" do
      stdout.gets # Start up message
      stdout.gets # Prompt
      stdin.puts("exit")

      expect(stdout.gets).to match(/Exiting/)
      expect(thread).not_to be_alive
    end

    it "sends input to the robot" do
      Lita::Message.stub(:new).and_return(message)
      robot.should_receive(:receive).with(message)

      stdout.gets # Start up message
      stdout.gets # Prompt
      stdin.puts("foo")
      stdout.gets # Block until the next loop iteration to ensure the code ran
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
