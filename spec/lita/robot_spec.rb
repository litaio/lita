require "spec_helper"

describe Lita::Robot do
  subject do
    described_class.new(Lita.config)
  end

  let(:adapter_class) do
    adapter = mock("adapter class")
    adapter.stub(:new) { adapter }
    adapter
  end

  let(:adapter) { double("adapter") }

  before { Lita::Adapter.stub(:load_adapter) { adapter_class } }

  it "delegates #run to #adapter" do
    subject.adapter.should_receive(:run)
    subject.run
  end

  it "delegates #say to #adapter" do
    subject.adapter.should_receive(:say)
    subject.say
  end

  it "delegates #reply to #adapter" do
    subject.adapter.should_receive(:reply)
    subject.reply
  end
end
