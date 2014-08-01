require "spec_helper"

describe Lita::Daemon do
  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }
  let(:log_file) { StringIO.new }

  before do
    allow(Process).to receive(:daemon)
    allow(Process).to receive(:kill)
    allow(File).to receive(:new).and_return("log")
    allow(File).to receive(:open)
    allow(File).to receive(:read)
    stub_const("STDOUT", stdout)
    stub_const("STDERR", stderr)
  end

  subject { described_class.new("/tmp/lita_pid", "/tmp/lita_log", false) }

  describe "#daemonize" do
    it "daemonizes the running process" do
      expect(Process).to receive(:daemon).with(true)
      subject.daemonize
    end

    context "when the user has not requested that existing processes should be killed" do
      it "aborts if a Lita process is already running" do
        allow(File).to receive(:exist?).and_return(true)
        expect(subject).to receive(:abort)
        subject.daemonize
      end
    end

    context "when the user has requested that existing process be killed" do
      subject { described_class.new("/tmp/lita_pid", "/tmp/lita_log", true) }

      it "kills existing processes" do
        allow(File).to receive(:exist?).and_return(true)
        expect(Process).to receive(:kill)
        subject.daemonize
      end

      it "aborts if it can't kill an existing process" do
        allow(File).to receive(:exist?).and_return(true)
        allow(Process).to receive(:kill).and_raise(Errno::ESRCH)
        expect(subject).to receive(:abort)
        subject.daemonize
      end
    end

    it "redirects stdout to the log file" do
      allow(File).to receive(:new).with("/tmp/lita_log", "a").and_return(log_file)
      subject.daemonize
      stdout.write "foo"
      expect(log_file.string).to eq("foo")
    end

    it "redirects stderr to the log file" do
      allow(File).to receive(:new).with("/tmp/lita_log", "a").and_return(log_file)
      subject.daemonize
      stderr.write "bar"
      expect(log_file.string).to eq("bar")
    end
  end
end
