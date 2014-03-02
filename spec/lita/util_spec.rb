require "spec_helper"

describe Lita::Util do
  describe ".stringify_keys" do
    it "converts symbol hash keys to strings" do
      stringified = described_class.stringify_keys(foo: "bar")
      expect(stringified).to eq("foo" => "bar")
    end
  end

  describe ".underscore" do
    it "converts camel cased strings into snake case" do
      expect(described_class.underscore("FooBarBaz")).to eq("foo_bar_baz")
    end
  end
end
