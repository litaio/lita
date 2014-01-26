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
    expect(subject).to be_a_private_message
  end

  it "can be manually marked as private" do
    subject = described_class.new(user: "Carl", room: "#litabot")
    subject.private_message!
    expect(subject).to be_a_private_message
  end

  it "requires either a user or a room" do
    expect { described_class.new }.to raise_error(ArgumentError)
  end
end
