require "spec_helper"

require "lita/feature_flag"

describe Lita::FeatureFlag do
  subject do
    described_class.new(:async_dispatch, description, "1000.0.0")
  end

  let(:description) do
    "Messages are dispatched to chat routes asynchronously."
  end

  it "has a name" do
    expect(subject.name).to eq(:async_dispatch)
  end

  it "includes a description" do
    expect(subject.description).to eq(description)
  end

  it "includes a version at which it is enabled by default" do
    expect(subject.version_threshold).to eq("1000.0.0")
  end

  describe "#opt_in_warning_for" do
    it "provides a warning message for a feature that has not been enabled" do
      object = Object.new

      expect(subject.opt_in_warning_for(object)).to eq <<MSG.chomp
WARNING: In Lita 1000.0.0, the following behavior will change:

  Messages are dispatched to chat routes asynchronously.

To opt-in to the new behavior now, add this code to the object `Object`:

   feature :async_dispatch
MSG
    end
  end

  describe "#flag_removal_warning_for" do
    it "provides a warning message for an enabled feature that is now the default" do
      object = Object.new

      expect(subject.flag_removal_warning_for(object)).to eq <<MSG.chomp
WARNING: Object `Object` explicitly enables the feature "async_dispatch", but this behavior is the \
default as of Lita 1000.0.0. You should remove `feature :async_dispatch` from the object now, \
because it will be removed completely and cause an error in Lita 1001.0.0.
MSG
    end
  end
end
