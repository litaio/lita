require "spec_helper"

describe Lita::TemplateResolver do
  subject do
    described_class.new(template_root, template_name, adapter_name)
  end

  let(:adapter_name) { :shell }
  let(:generic_template) { File.join(template_root, "basic.erb") }
  let(:irc_template) { File.join(template_root, "basic.irc.erb") }
  let(:template_name) { "basic" }
  let(:template_root) { File.expand_path(File.join("..", "..", "templates"), __FILE__) }

  describe "#resolve" do
    context "when there is a template for the adapter" do
      let(:adapter_name) { :irc }

      it "returns the path to the adapter-specific template" do
        expect(subject.resolve).to eq(irc_template)
      end
    end

    context "when there is no template for the adapter" do
      it "returns the path for the generic template" do
        expect(subject.resolve).to eq(generic_template)
      end
    end

    context "when there is no template with the given name" do
      let(:template_name) { "nonexistent" }

      it "raises an exception" do
        expect { subject.resolve }.to raise_error(
          Lita::MissingTemplateError,
          %r{templates/nonexistent\.erb}
        )
      end
    end
  end
end
