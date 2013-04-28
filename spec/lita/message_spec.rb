require "spec_helper"

describe Lita::Message do
  let(:user) { double("user") }

  it "stores the raw message as #body" do
    message = described_class.new("foo", user)
    expect(message.body).to eq("foo")
  end

  it "stores the user who sent the message" do
    message = described_class.new("foo", user)
    expect(message.user).to eql(user)
  end

  it "uses the body as its string representation" do
    message = described_class.new("foo", user)
    expect("#{message}").to eq("foo")
  end
end
