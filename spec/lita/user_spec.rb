require "spec_helper"

describe Lita::User, lita: true do
  describe ".create" do
    it "creates and returns new users" do
      user = described_class.create(1, name: "Carl")
      expect(user.id).to eq("1")
      expect(user.name).to eq("Carl")
      persisted_user = described_class.find(1)
      expect(user).to eq(persisted_user)
    end
  end

  describe ".find" do
    before { described_class.create(1, name: "Carl") }

    it "returns existing users" do
      expect_any_instance_of(described_class).not_to receive(:save)
      user = described_class.find(1, name: "Carl")
      expect(user.id).to eq("1")
      expect(user.name).to eq("Carl")
    end
  end

  describe ".find_by_name" do
    it "returns nil if no user matches the provided name" do
      expect(described_class.find_by_name("Carl")).to be_nil
    end

    it "returns existing users" do
      described_class.create(1, name: "Carl")
      user = described_class.find_by_name("Carl")
      expect(user.id).to eq("1")
    end
  end

  describe ".find_by_partial_name" do
    before { described_class.create(1, name: "José Vicente Cuadra") }

    it "finds users by partial name match" do
      user = described_class.find_by_partial_name("José")
      expect(user.id).to eq("1")
    end

    it "returns nil if no users' names start with the provided string" do
      expect(described_class.find_by_partial_name("Foo")).to be_nil
    end

    it "returns nil if more than one match was found" do
      described_class.create(2, name: "José Contreras")
      expect(described_class.find_by_partial_name("José")).to be_nil
    end
  end

  describe "#save" do
    subject { described_class.new(1, name: "Carl") }

    it "saves an ID to name mapping for the user in Redis" do
      subject.save
      expect(described_class.redis.hgetall("id:1")).to eq("name" => "Carl")
    end

    it "saves a name to ID mapping for the user in Redis" do
      subject.save
      expect(described_class.redis.get("name:Carl")).to eq("1")
    end
  end

  describe "#==" do
    it "considers two users equal if they share an ID and name" do
      user1 = described_class.new(1, name: "Carl")
      user2 = described_class.new(1, name: "Carl")
      expect(user1).to eq(user2)
    end

    it "doesn't assume the comparison object is a Lita::User" do
      user = described_class.new(1, name: "Carl")
      expect(user).not_to eq("not a Lita::User object")
    end
  end
end
