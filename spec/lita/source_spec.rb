require "spec_helper"

describe Lita::Source do
  subject { described_class.new(user: user, room: room, private_message: pm) }

  let(:pm) { false }
  let(:room) { Lita::Room.new(1) }
  let(:user) { Lita::User.new(1) }

  describe "#room" do
    it "returns the room as a string" do
      expect(subject.room).to eq("1")
    end
  end

  describe "#room_object" do
    it "returns the room as a Lita::Room" do
      expect(subject.room_object).to eq(room)
    end
  end

  describe "#user" do
    it "returns the user object" do
      expect(subject.user).to eq(user)
    end
  end

  context "when the private_message argument is true" do
    let(:pm) { true }

    it "is marked as a private message" do
      expect(subject).to be_a_private_message
    end
  end

  it "can be manually marked as private" do
    subject.private_message!

    expect(subject).to be_a_private_message
  end

  context "with a string for the room argument" do
    let(:room) { "#channel" }

    it "sets #room to the string" do
      expect(subject.room).to eq(room)
    end

    it "sets #room_object to a Lita::Room with the string as its ID" do
      expect(subject.room_object).to eq(Lita::Room.new(room))
    end
  end

  it "requires either a user or a room" do
    expect { described_class.new }.to raise_error(ArgumentError)
  end
end
