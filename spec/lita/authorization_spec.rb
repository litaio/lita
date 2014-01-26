require "spec_helper"

describe Lita::Authorization, lita: true do
  let(:requesting_user) { double("Lita::User", id: "1") }
  let(:user) { double("Lita::User", id: "2") }

  before do
    Lita.config.robot.admins = ["1"]
  end

  describe ".add_user_to_group" do
    it "adds users to an auth group" do
      described_class.add_user_to_group(requesting_user, user, "employees")
      expect(described_class.user_in_group?(user, "employees")).to be true
    end

    it "can only be called by admins" do
      Lita.config.robot.admins = nil
      result = described_class.add_user_to_group(
        requesting_user,
        user,
        "employees"
      )
      expect(result).to eq(:unauthorized)
      expect(described_class.user_in_group?(user, "employees")).to be false
    end

    it "normalizes the group name" do
      described_class.add_user_to_group(requesting_user, user, "eMPLoYeeS")
      expect(described_class.user_in_group?(user, "  EmplOyEEs  ")).to be true
    end
  end

  describe ".remove_user_from_group" do
    it "removes users from an auth group" do
      described_class.add_user_to_group(requesting_user, user, "employees")
      described_class.remove_user_from_group(requesting_user, user, "employees")
      expect(described_class.user_in_group?(user, "employees")).to be false
    end

    it "can only be called by admins" do
      described_class.add_user_to_group(requesting_user, user, "employees")
      Lita.config.robot.admins = nil
      result = described_class.remove_user_from_group(
        requesting_user,
        user,
        "employees"
      )
      expect(result).to eq(:unauthorized)
      expect(described_class.user_in_group?(user, "employees")).to be true
    end

    it "normalizes the group name" do
      described_class.add_user_to_group(requesting_user, user, "eMPLoYeeS")
      described_class.remove_user_from_group(requesting_user, user, "EmployeeS")
      expect(described_class.user_in_group?(user, "  EmplOyEEs  ")).to be false
    end
  end

  describe ".user_in_group?" do
    it "returns false if the user is in the group" do
      expect(described_class.user_in_group?(user, "employees")).to be false
    end

    it "delegates to .user_is_admin? if the group is admins" do
      expect(described_class).to receive(:user_is_admin?)
      described_class.user_in_group?(user, "admins")
    end
  end

  describe ".user_is_admin?" do
    it "returns true if the user's ID is in the config" do
      expect(described_class.user_is_admin?(requesting_user)).to be true
    end

    it "returns false if the user's ID is not in the config" do
      Lita.config.robot.admins = nil
      expect(described_class.user_is_admin?(user)).to be false
    end
  end

  describe ".groups" do
    before do
      %i{foo bar baz}.each do |group|
        described_class.add_user_to_group(requesting_user, user, group)
      end
    end

    it "returns a list of all authorization groups" do
      expect(described_class.groups).to match_array(%i{foo bar baz})
    end
  end

  describe ".groups_with_users" do
    before do
      %i{foo bar baz}.each do |group|
        described_class.add_user_to_group(requesting_user, user, group)
        described_class.add_user_to_group(
          requesting_user,
          requesting_user,
          group
        )
      end
      allow(Lita::User).to receive(:find_by_id).with("1").and_return(
        requesting_user
      )
      allow(Lita::User).to receive(:find_by_id).with("2").and_return(user)
    end

    it "returns a hash of all authorization groups and their members" do
      groups = %i{foo bar baz}
      groups_with_users = described_class.groups_with_users
      expect(groups_with_users.keys).to match_array(groups)
      groups.each do |group|
        expect(groups_with_users[group]).to match_array([user, requesting_user])
      end
    end
  end
end
