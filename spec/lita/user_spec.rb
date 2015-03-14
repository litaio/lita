require "spec_helper"

describe Lita::User, lita: true do
  describe ".create" do
    it "creates and returns new users" do
      user = described_class.create(1, name: "Carl")
      expect(user.id).to eq("1")
      expect(user.name).to eq("Carl")
      persisted_user = described_class.find_by_id(1)
      expect(user).to eq(persisted_user)
    end

    it "returns existing users" do
      described_class.create(1, name: "Carl")
      user = described_class.find_by_id(1)
      expect(user.id).to eq("1")
      expect(user.name).to eq("Carl")
    end

    it "merges and saves new metadata for existing users" do
      described_class.create(1, name: "Carl")
      described_class.create(1, name: "Mr. Carl", foo: "bar")
      user = described_class.find_by_id(1)
      expect(user.name).to eq("Mr. Carl")
      expect(user.metadata["foo"]).to eq("bar")
    end
  end

  describe ".find_by_id" do
    it "finds users with no metadata stored" do
      described_class.create(1)
      user = described_class.find_by_id(1)
      expect(user.id).to eq("1")
    end
  end

  describe ".find_by_mention_name" do
    it "returns nil if no user matches the provided mention name" do
      expect(described_class.find_by_mention_name("carlthepug")).to be_nil
    end

    it "returns a user that matches the provided mention name" do
      described_class.create(1, mention_name: "carlthepug")
      user = described_class.find_by_mention_name("carlthepug")
      expect(user.id).to eq("1")
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

  describe ".fuzzy_find" do
    let!(:user) { described_class.create(1, name: "Carl the Pug", mention_name: "carlthepug") }

    it "finds by ID" do
      expect(described_class.fuzzy_find(1)).to eq(user)
    end

    it "finds by mention name" do
      expect(described_class.fuzzy_find("carlthepug")).to eq(user)
    end

    it "finds by name" do
      expect(described_class.fuzzy_find("Carl the Pug")).to eq(user)
    end

    it "finds by partial mention name" do
      expect(described_class.fuzzy_find("Carl")).to eq(user)
    end
  end

  describe "#mention_name" do
    it "returns the user's mention name from metadata" do
      subject = described_class.new(1, name: "Carl", mention_name: "carlthepug")
      expect(subject.mention_name).to eq("carlthepug")
    end

    it "returns the user's name if there is no mention name in the metadata" do
      subject = described_class.new(1, name: "Carl")
      expect(subject.mention_name).to eq("Carl")
    end
  end

  describe "#save" do
    subject { described_class.new(1, name: "Carl", mention_name: "carlthepug") }

    it "saves an ID to name mapping for the user in Redis" do
      subject.save
      expect(described_class.redis.hgetall("id:1")).to include("name" => "Carl")
    end

    it "saves a name to ID mapping for the user in Redis" do
      subject.save
      expect(described_class.redis.get("name:Carl")).to eq("1")
    end

    it "saves a mention name to ID mapping for the user in Redis" do
      subject.save
      expect(described_class.redis.get("mention_name:carlthepug")).to eq("1")
    end
  end

  describe "equality" do
    it "considers two users equal if they share an ID and name" do
      user1 = described_class.new(1, name: "Carl")
      user2 = described_class.new(1, name: "Carl")
      expect(user1).to eq(user2)
      expect(user1).to eql(user2)
    end

    it "doesn't assume the comparison object is a Lita::User" do
      user = described_class.new(1, name: "Carl")
      expect(user).not_to eq("not a Lita::User object")
      expect(user).not_to eql("not a Lita::User object")
    end

    it "consistently hashes equal users" do
      user1 = described_class.new(1, name: "Carl")
      user2 = described_class.new(1, name: "Carl")

      expect(user1.hash).to eq(user2.hash)
    end
  end
end
