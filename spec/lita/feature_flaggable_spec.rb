require "spec_helper"

require "lita/feature_flaggable"

describe Lita::FeatureFlaggable do
  subject do
    Class.new do
      extend Lita::FeatureFlaggable
    end
  end

  it "has no features enabled by default" do
    expect(subject.enabled_features).to be_empty
  end

  it "can enable a feature" do
    subject.feature :async_dispatch

    expect(subject.feature_enabled?(:async_dispatch)).to be(true)
  end

  it "raises an exception when attempting to enable an unknown feature" do
    expect do
      subject.feature :foo
    end.to raise_error(Lita::UnknownFeatureError, 'Cannot enable unknown feature "foo"')
  end
end
