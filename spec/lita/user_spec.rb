require "spec_helper"

describe Lita::User do
  let(:robot) { double("robot") }

  it "stores a user ID" do
    user = described_class.new(robot, "Bongo")
    expect(user.id).to eq("Bongo")
  end

  it "uses the ID as its string representation" do
    user = described_class.new(robot, "Bongo")
    expect("#{user}").to eq("Bongo")
  end
end
