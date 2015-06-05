require "spec_helper"

describe Lita::Room, lita: true do
  describe ".create_or_update" do
    subject { described_class.find_by_id(1) }

    context "when no room with the given ID already exists" do
      it "creates the room" do
        described_class.create_or_update(1, name: "foo")

        expect(subject.name).to eq("foo")
      end
    end

    context "when a room with the given ID already exists" do
      before { described_class.create_or_update(1, name: "foo") }

      it "merges in new metadata" do
        described_class.create_or_update(1, foo: "bar")

        expect(subject.name).to eq("foo")
        expect(subject.metadata["foo"]).to eq("bar")
      end
    end
  end

  describe ".find_by_id" do
    context "when a matching room exists" do
      before { described_class.new(1).save }

      it "is found by ID" do
        expect(described_class.find_by_id(1).id).to eq("1")
      end
    end

    context "when no matching room exists" do
      it "is not found" do
        expect(described_class.find_by_id(1)).to be_nil
      end
    end
  end

  describe ".find_by_name" do
    context "when a matching room exists" do
      before { described_class.new(1, name: "foo").save }

      it "is found by name" do
        expect(described_class.find_by_name("foo").id).to eq("1")
      end
    end

    context "when no matching room exists" do
      it "is not found" do
        expect(described_class.find_by_name("foo")).to be_nil
      end
    end
  end

  describe ".fuzzy_find" do
    context "when a matching room exists" do
      before { described_class.new(1, name: "foo").save }

      it "is found by ID" do
        expect(described_class.fuzzy_find(1).id).to eq("1")
      end

      it "is found by name" do
        expect(described_class.fuzzy_find("foo").id).to eq("1")
      end
    end

    context "when no matching room exists" do
      it "is not found by ID" do
        expect(described_class.fuzzy_find(1)).to be_nil
      end

      it "is not found by name" do
        expect(described_class.fuzzy_find("foo")).to be_nil
      end
    end
  end

  context "with only an ID" do
    subject { described_class.new(1) }

    it "has a string ID" do
      expect(subject.id).to eq("1")
    end

    it "is named with its ID" do
      expect(subject.name).to eq("1")
    end
  end

  context "with metadata" do
    subject { described_class.new(1, foo: :bar) }

    it "stores the metadata with string keys" do
      expect(subject.metadata["foo"]).to eq(:bar)
    end
  end

  describe "#==" do
    subject { described_class.new(1) }

    context "when the other room has the same ID" do
      let(:other) { described_class.new(1) }

      it "is equal" do
        expect(subject).to eq(other)
      end
    end

    context "when the other room has a different ID" do
      let(:other) { described_class.new(2) }

      it "is not equal" do
        expect(subject).not_to eq(other)
      end
    end
  end

  describe "#save" do
    context "with metadata not including name" do
      subject { described_class.new(1, {}) }

      it "adds the name to the metadata" do
        subject.save

        expect(subject.metadata["name"]).to eq("1")
      end
    end
  end
end
