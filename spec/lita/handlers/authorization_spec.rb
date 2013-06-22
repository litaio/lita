require "spec_helper"

describe Lita::Handlers::Authorization, lita: true do
  before { allow(robot).to receive(:send_messages) }

  it { routes("#{robot.name}: auth add foo bar").to(:add) }
  it { routes("#{robot.name}: auth add foo@bar.com baz").to(:add) }
  it { routes("#{robot.name}: auth remove foo bar").to(:remove) }
  it { routes("#{robot.name}: auth remove foo@bar.com baz").to(:remove) }

  describe ".help" do
    it "returns a hash of command help" do
      expect(described_class.help).to be_a(Hash)
    end
  end

  describe "#add" do
    before do
      allow(Lita::Authorization).to receive(:user_is_admin?).and_return(true)
    end

    it "replies with the proper format if the require commands are missing" do
      expect_reply(/^Format:/)
      send_test_message("#{robot.name}: auth add foo")
    end

    it "replies with a warning if target user is not known" do
      expect_reply(/No user was found/)
      send_test_message("#{robot.name}: auth add foo bar")
    end

    it "replies with success if the valid user ID and group were supplied" do
      allow(Lita::User).to receive(:find_by_id).and_return(user)
      expect_reply("#{user.name} was added to bar.")
      send_test_message("#{robot.name}: auth add foo bar")
    end

    it "replies with success if the valid user ID and group were supplied" do
      allow(Lita::User).to receive(:find_by_name).and_return(user)
      expect_reply("#{user.name} was added to bar.")
      send_test_message("#{robot.name}: auth add foo bar")
    end

    it "replies with a warning if the user was already in the group" do
      allow(Lita::User).to receive(:find_by_id).and_return(user)
      send_test_message("#{robot.name}: auth add foo bar")
      expect_reply("#{user.name} was already in bar.")
      send_test_message("#{robot.name}: auth add foo bar")
    end
  end

  describe "#remove" do
    before do
      allow(Lita::Authorization).to receive(:user_is_admin?).and_return(true)
      allow(Lita::User).to receive(:find_by_id).and_return(user)
      send_test_message("#{robot.name}: auth add foo bar")
    end

    it "replies with success if the valid user ID and group were supplied" do
      expect_reply("#{user.name} was removed from bar.")
      send_test_message("#{robot.name}: auth remove foo bar")
    end

    it "replies with a warning if the user was already in the group" do
      send_test_message("#{robot.name}: auth remove foo bar")
      expect_reply("#{user.name} was not in bar.")
      send_test_message("#{robot.name}: auth remove foo bar")
    end
  end
end
