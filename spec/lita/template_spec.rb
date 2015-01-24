require "spec_helper"

describe Lita::Template do
  describe ".from_file" do
    context "with a path to an ERB template" do
      subject do
        described_class.from_file(File.expand_path("../../templates/basic.erb", __FILE__))
      end

      it "uses the source in the file" do
        expect(subject.render).to eq("Template rendered from a file!")
      end
    end
  end

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
