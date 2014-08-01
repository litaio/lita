require "spec_helper"

describe Lita::Handlers::Authorization, lita_handler: true do
  before do
    allow(robot.auth).to receive(:user_is_admin?).with(user).and_return(true)
  end

  let(:target_user) { instance_double("Lita::User", id: "1", name: "Carl") }

  it { is_expected.to route_command("auth add foo bar").to(:add) }
  it { is_expected.to route_command("auth add foo@bar.com baz").to(:add) }
  it { is_expected.to route_command("auth remove foo bar").to(:remove) }
  it { is_expected.to route_command("auth remove foo@bar.com baz").to(:remove) }
  it { is_expected.to route_command("auth list").to(:list) }
  it { is_expected.to route_command("auth list foo").to(:list) }

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

    it 'replies with a warning if the group was "admins"' do
      send_command("auth add foo admins")
      expect(replies.last).to match(/Administrators can only be managed/)
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

    it 'replies with a warning if the group was "admins"' do
      send_command("auth add foo admins")
      expect(replies.last).to match(/Administrators can only be managed/)
    end
  end

  describe "#list" do
    context "when there are populated groups" do
      let(:groups) { %i(foo bar) }
      let(:user1) { Lita::User.create(3, name: "Bongo") }
      let(:user2) { Lita::User.create(4, name: "Carl") }

      before do
        groups.each do |group|
          subject.robot.auth.add_user_to_group(user, user1, group)
          subject.robot.auth.add_user_to_group(user, user2, group)
        end
      end

      it "lists all authorization groups and their members" do
        send_command("auth list")
        groups.each do |group|
          expect(replies.last).to include(
            "#{group}: #{user1.name}, #{user2.name}"
          )
        end
      end

      it "lists only the requested group" do
        send_command("auth list foo")
        expect(replies.last).to include("foo")
        expect(replies.last).not_to include("bar")
      end
    end

    it "replies that there are no groups" do
      send_command("auth list")
      expect(replies.last).to include("no authorization groups yet")
    end

    it "replies that the specified group doesn't exist" do
      send_command("auth list nothing")
      expect(replies.last).to include("no authorization group named nothing")
    end
  end
end
