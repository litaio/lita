require "spec_helper"

describe Lita::Source do
  it "has a user" do
    subject = described_class.new("Carl")
    expect(subject.user).to eq("Carl")
  end

  it "has a room" do
    subject = described_class.new("Carl", "#litabot")
    expect(subject.room).to eq("#litabot")
  end
end
