require "spec_helper"

describe Lita::ConfigBuilder do
  let(:config) { subject.config }

  it "doesn't respond to anything by default" do
    expect { config.foo }.to raise_error(NoMethodError)
  end

  describe "#add_attribute" do
    let(:attribute) { double("Lita::ConfigurationAttribute", name: :foo) }

    it "adds a getter" do
      subject.add_attribute(attribute)
      expect(attribute).to receive(:get)
      config.foo
    end

    it "adds a setter" do
      subject.add_attribute(attribute)
      expect(attribute).to receive(:set).with("bar")
      config.foo = "bar"
    end
  end
end
