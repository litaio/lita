require "spec_helper"

describe Lita::ConfigAttribute do
  let(:subject) { described_class.new(:foo) }

  it "has a normalized name" do
    expect(described_class.new(" tHe NAme ").name).to eq(:the_name)
  end

  it "can set and get a value" do
    subject.set("foo")
    expect(subject.get).to eq("foo")
  end

  describe "#types" do
    it "has an array of valid types" do
      subject.types = [Symbol, String]
      expect(subject.types).to eq([Symbol, String])
    end
  end
end
