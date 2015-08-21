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

  describe "#add_helper" do
    subject { described_class.new("<%= reverse_name(@first, @last) %>") }
    let(:helper) do
      Module.new do
        def reverse_name(first, last)
          "#{last}, #{first}"
        end
      end
    end

    it "adds the helper to the evaluation context" do
      subject.add_helper(helper)

      expect(subject.render(first: "Carl", last: "Pug")).to eq("Pug, Carl")
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
