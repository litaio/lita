require "spec_helper"

describe Lita::Handlers::Room, lita_handler: true do
  it { is_expected.to route_command("join #lita.io").to(:join) }
  it { is_expected.to route_command("part #lita.io").to(:part) }

  before { allow(robot.auth).to receive(:user_is_admin?).with(user).and_return(true) }

  describe "#join" do
    it "calls Robot#join with the provided ID" do
      expect(robot).to receive(:join).with("#lita.io")
      send_command("join #lita.io")
    end
  end

  describe "#part" do
    it "calls Robot#part with the provided ID" do
      expect(robot).to receive(:part).with("#lita.io")
      send_command("part #lita.io")
    end
  end
end
