require "spec_helper"

describe Lita::Store do
  it "has nil values by default" do
    expect(subject[:foo]).to be_nil
  end

  it "sets and gets values" do
    subject[:foo] = :bar

    expect(subject[:foo]).to eq(:bar)
  end

  it "allows a custom internal store" do
    subject = described_class.new(Hash.new { |h, k| h[k] = described_class.new })

    subject[:foo][:bar] = :baz

    expect(subject[:foo][:bar]).to eq(:baz)
  end
end
