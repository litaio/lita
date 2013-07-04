require "spec_helper"

describe Lita::Util do
  describe ".underscore" do
    it "converts camel cased strings into snake case" do
      expect(described_class.underscore("FooBarBaz")).to eq("foo_bar_baz")
    end
  end
end
