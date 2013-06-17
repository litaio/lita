require "spec_helper"

describe Lita::User, lita_handler: true do
  describe ".create" do
    it "creates and returns new users" do
      user = described_class.create(1, "Carl")
      expect(user.id).to eq("1")
      expect(user.name).to eq("Carl")
      persisted_user = described_class.create(1, "Carl")
      expect(user).to eq(persisted_user)
    end

    it "returns existing users" do
      described_class.create(1, "Carl")
      expect_any_instance_of(described_class).not_to receive(:save)
      user = described_class.create(1, "Carl")
      expect(user.id).to eq("1")
      expect(user.name).to eq("Carl")
    end
  end

  describe ".find" do
    it "returns nil if no user matches the provided ID" do
      expect(described_class.find(1)).to be_nil
    end

    it "returns existing users" do
      described_class.create(1, "Carl")
      user = described_class.find(1)
      expect(user.name).to eq("Carl")
    end
  end

  describe ".find_by_name" do
    it "returns nil if no user matches the provided name" do
      expect(described_class.find_by_name("Carl")).to be_nil
    end

    it "returns existing users" do
      described_class.create(1, "Carl")
      user = described_class.find_by_name("Carl")
      expect(user.id).to eq("1")
    end
  end

  describe "#save" do
    subject { described_class.new(1, "Carl") }

    it "saves an ID to name mapping for the user in Redis" do
      subject.save
      expect(described_class.redis.get("id:1")).to eq("Carl")
    end

    it "saves a name to ID mapping for the user in Redis" do
      subject.save
      expect(described_class.redis.get("name:Carl")).to eq("1")
    end
  end

  describe "#==" do
    it "considers two users equal if they share an ID and name" do
      user1 = described_class.new(1, "Carl")
      user2 = described_class.new(1, "Carl")
      expect(user1).to eq(user2)
    end
  end
end
