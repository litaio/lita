require "spec_helper"

describe Lita::Source do
  it "has a user" do
    subject = described_class.new(user: "Carl")
    expect(subject.user).to eq("Carl")
  end

  it "has a room" do
    subject = described_class.new(room: "#litabot")
    expect(subject.room).to eq("#litabot")
  end

  it "has a private message flag" do
    subject = described_class.new(user: "Carl", private_message: true)
    expect(subject.private_message).to be_true
  end

  it "requires either a user or a room" do
    expect { described_class.new }.to raise_error(ArgumentError)
  end

  describe "the deprecated Source.new(user, room) API" do
    it "can have a user and is marked as private if there is no room" do
      expect(Lita.logger).to receive(:warn)
      subject = described_class.new("Carl")
      expect(subject.user).to eq("Carl")
      expect(subject).to be_a_private_message
    end

    it "can have a room and is not marked as private if it does" do
      expect(Lita.logger).to receive(:warn)
      subject = described_class.new("Carl", "#litabot")
      expect(subject.room).to eq("#litabot")
      expect(subject).not_to be_a_private_message
    end
  end
end
