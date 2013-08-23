require "spec_helper"

describe Lita::Response do
  subject { described_class.new(message) }

  let(:message) { double("Lita::Message").as_null_object }

  [:args, :reply, :user, :command?].each do |method|
    it "delegates :#{method} to #message" do
      expect(message).to receive(method)
      subject.public_send(method)
    end
  end
end
