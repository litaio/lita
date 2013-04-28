require "spec_helper"

describe Lita::Adapters::Shell do
  subject do
    described_class.new(robot, config, stdout: stdout, stdin: stdin)
  end

  let(:robot) { double("robot") }
  let(:config) { double("config") }
  let(:stdout) { double("stdout") }
  let(:stdin) { double("stdin") }

  describe "#say" do
    it "writes messages to stdout" do
      stdout.should_receive(:puts).with("foo")
      stdout.should_receive(:puts).with("bar")
      subject.say("foo", "bar")
    end
  end
end
