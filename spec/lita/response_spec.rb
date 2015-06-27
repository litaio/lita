require "spec_helper"

describe Lita::Response do
  subject { described_class.new(message, /dummy regexp/) }

  let(:message) { instance_double("Lita::Message").as_null_object }

  [:args, :reply, :reply_privately, :reply_with_mention, :user, :command?].each do |method|
    it "delegates :#{method} to #message" do
      expect(message).to receive(method)
      subject.public_send(method)
    end
  end

  describe "#matches" do
    it "matches the pattern against the message" do
      expect(message).to receive(:match).with(subject.pattern)
      subject.matches
    end
  end

  describe "#match_data" do
    let(:body) { instance_double("String") }

    it "matches the message body against the pattern" do
      allow(message).to receive(:body).and_return(body)
      expect(subject.pattern).to receive(:match).with(message.body)
      subject.match_data
    end
  end

  describe "#extensions" do
    it "can be populated with arbitrary data" do
      subject.extensions[:foo] = :bar

      expect(subject.extensions[:foo]).to eq(:bar)
    end
  end

  describe "#user" do
    it "delegates to #message" do
      expect(subject.message).to receive(:user)
      subject.user
    end
  end

  describe "#room" do
    it "delegates to #message" do
      expect(subject.message).to receive(:room_object)
      subject.room
    end
  end

  describe "#private_message?" do
    it "delegates to #message" do
      expect(subject.message).to receive(:private_message?)
      subject.private_message?
    end
  end
end
