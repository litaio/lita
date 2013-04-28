require "spec_helper"

describe Lita::Adapters::Shell do
  subject { described_class.new(robot, config, stdout: stdout, stdin: stdin) }

  let(:robot) { double("robot") }
  let(:config) { double("config") }
  let(:stdout) { StringIO.new }
  let(:stdin) { StringIO.new }
  let!(:thread) { Thread.new { subject.run } }

  after { thread.kill if thread.alive? }

  describe "#run" do
    it "displays a message about how to exit on start up" do
      expect(stdout.string).to match(/exit/)
    end
  end
end
