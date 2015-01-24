require "spec_helper"

describe Lita::Template do
  describe "#render" do
    context "with a static source template" do
      subject { described_class.new("Hello, Lita!") }

      it "renders the text" do
        expect(subject.render).to eq("Hello, Lita!")
      end
    end

    context "with interpolation variables" do
      subject { described_class.new("Hello, <%= @name %>!") }

      it "renders the text with interpolated values" do
        expect(subject.render(name: "Carl")).to eq("Hello, Carl!")
      end
    end
  end
end
