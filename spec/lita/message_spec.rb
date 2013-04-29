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

  describe "#parse_command" do
    it "is true if prefixed by the bot's name and a colon" do
      message = described_class.new("Lita: foo bar", user)
      expect(message.parse_command("Lita")).to eq(["foo", "bar"])
    end

    it "is true if prefixed with an at symbol and the bot's name" do
      message = described_class.new("@Lita foo bar", user)
      expect(message.parse_command("Lita")).to eq(["foo", "bar"])
    end

    it "is not case sensitive" do
      message = described_class.new("lita: foo bar", user)
      expect(message.parse_command("Lita")).to eq(["foo", "bar"])
    end

    it "ignores whitespace on either side of the prefix and between args" do
      message = described_class.new(" lita:foo  bar", user)
      expect(message.parse_command("Lita")).to eq(["foo", "bar"])
    end

    it "does not match messages without an appropriate prefix" do
      message = described_class.new("foo", user)
      expect(message.parse_command("Lita")).to be_nil
    end

    it "escapes messages that cannot be shellsplit as is" do
      message = described_class.new("Lita: foo 'bar", user)
      expect(message.parse_command("Lita")).to eq(["foo", "'bar"])
    end
  end
end
