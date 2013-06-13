require "spec_helper"

describe Lita::Message do
  subject do
    described_class.new("Hello", "Carl")
  end

  it "has a body" do
    expect(subject.body).to eq("Hello")
  end

  it "aliases #body with #message" do
    expect(subject.message).to eq("Hello")
  end

  it "has a source" do
    expect(subject.source).to eq("Carl")
  end
end
