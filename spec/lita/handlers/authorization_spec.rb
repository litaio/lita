require "spec_helper"

describe Lita::Handlers::Authorization, lita_handler: true do
  before do
    allow(Lita::Authorization).to receive(:user_is_admin?).with(
      user
    ).and_return(true)
  end

  let(:target_user) { double("Lita::User", id: "1", name: "Carl") }

  it { routes_command("auth add foo bar").to(:add) }
  it { routes_command("auth add foo@bar.com baz").to(:add) }
  it { routes_command("auth remove foo bar").to(:remove) }
  it { routes_command("auth remove foo@bar.com baz").to(:remove) }

  describe "#add" do
    it "replies with the proper format if the require commands are missing" do
      send_command("auth add foo")
      expect(replies.last).to match(/^Format:/)
    end

    it "replies with a warning if target user is not known" do
      send_command("auth add foo bar")
      expect(replies.last).to match(/No user was found/)
    end

    it "replies with success if a valid user and group were supplied" do
      allow(Lita::User).to receive(:find_by_id).and_return(target_user)
      send_command("auth add foo bar")
      expect(replies.last).to eq("#{target_user.name} was added to bar.")
    end

    it "replies with a warning if the user was already in the group" do
      allow(Lita::User).to receive(:find_by_id).and_return(target_user)
      send_command("auth add foo bar")
      send_command("auth add foo bar")
      expect(replies.last).to eq("#{target_user.name} was already in bar.")
    end

    it "replies with a warning if the requesting user is not an admin" do
      allow(Lita::User).to receive(:find_by_id).and_return(target_user)
      allow(Lita::Authorization).to receive(:user_is_admin?).with(
        user
      ).and_return(false)
      send_command("auth add foo bar")
      expect(replies.last).to match(/Only administrators can add/)
    end
  end

  describe "#remove" do
    before do
      allow(Lita::User).to receive(:find_by_id).and_return(target_user)
      send_command("auth add foo bar")
    end

    it "replies with success if a valid user and group were supplied" do
      send_command("auth remove foo bar")
      expect(replies.last).to eq("#{target_user.name} was removed from bar.")
    end

    it "replies with a warning if the user was already in the group" do
      send_command("auth remove foo bar")
      send_command("auth remove foo bar")
      expect(replies.last).to eq("#{target_user.name} was not in bar.")
    end

    it "replies with a warning if the requesting user is not an admin" do
      allow(Lita::Authorization).to receive(:user_is_admin?).with(
        user
      ).and_return(false)
      send_command("auth remove foo bar")
      expect(replies.last).to match(/Only administrators can remove/)
    end
  end
end
