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

  let(:storage) { double("storage") }

  before do
    Lita::Adapter.stub(:load_adapter) { adapter_class }
    Lita::Storage.stub(:new) { storage }
  end

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

  it "has a name" do
    expect(subject.name).to eq("Lita")
  end

  it "has a storage object" do
    expect(subject.storage).to be(storage)
  end
end
