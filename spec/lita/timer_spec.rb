require "spec_helper"

describe Lita::Timer do
  let(:queue) { Queue.new }

  before { allow(subject).to receive(:sleep) }

  after { subject.stop }

  it "runs single timers" do
    subject = described_class.new { queue.push(true) }
    expect(subject).to receive(:sleep).with(0).once
    subject.start
    expect(queue.pop(true)).to be(true)
    expect { queue.pop(true) }.to raise_error(ThreadError)
  end

  it "runs recurring timers" do
    halt = false
    subject = described_class.new(interval: 1, recurring: true) do |timer|
      queue.push(true)
      timer.stop if halt
      halt = true
    end
    expect(subject).to receive(:sleep).with(1).twice
    subject.start
    2.times { expect(queue.pop(true)).to be(true) }
    expect { queue.pop(true) }.to raise_error(ThreadError)
  end
end
