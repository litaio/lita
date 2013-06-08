require "spec_helper"

describe Lita::Adapter do
  let(:robot) { double("Robot") }

  subject { described_class.new(robot) }

  it "stores a Robot" do
    expect(subject.robot).to eql(robot)
  end
end
