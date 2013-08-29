require "spec_helper"

describe Lita::Response do
  subject { described_class.new(message, pattern) }

  let(:message) { double("Lita::Message").as_null_object }
  let(:pattern) { double("Regexp").as_null_object }

  [:args, :reply, :user, :command?].each do |method|
    it "delegates :#{method} to #message" do
      expect(message).to receive(method)
      subject.public_send(method)
    end
  end

  it "supports the deprecated Response.new(message, matches: matches) API" do
    matches = ["foo"]
    expect(Lita.logger).to receive(:warn)
    subject = described_class.new(message, matches: matches)
    expect(subject.matches).to eq(matches)
  end
end
