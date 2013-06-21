require "spec_helper"

describe Lita::Authorization, lita: true do
  let(:user) do
    user = double("User")
    allow(user).to receive(:id).and_return("1")
    user
  end

  describe ".add_user_to_group" do
    it "adds users to an auth group" do
      allow(described_class).to receive(:user_is_admin?).and_return(true)
      described_class.add_user_to_group(user, "employees")
      expect(described_class.user_in_group?(user, "employees")).to be_true
    end

    it "can only be called by admins" do
      allow(described_class).to receive(:user_is_admin?).and_return(false)
      described_class.add_user_to_group(user, "employees")
      expect(described_class.user_in_group?(user, "employees")).to be_false
    end
  end

  describe ".remove_user_from_group" do
    it "removes users from an auth group" do
      allow(described_class).to receive(:user_is_admin?).and_return(true)
      described_class.add_user_to_group(user, "employees")
      described_class.remove_user_from_group(user, "employees")
      expect(described_class.user_in_group?(user, "employees")).to be_false
    end

    it "can only be called by admins" do
      allow(described_class).to receive(:user_is_admin?).and_return(true)
      described_class.add_user_to_group(user, "employees")
      allow(described_class).to receive(:user_is_admin?).and_return(false)
      described_class.remove_user_from_group(user, "employees")
      expect(described_class.user_in_group?(user, "employees")).to be_true
    end
  end

  describe ".user_in_group?" do
    # Positive case is covered by .add_user_to_group's example.

    it "returns false if the user is in the group" do
      expect(described_class.user_in_group?(user, "employees")).to be_false
    end
  end

  describe ".user_is_admin?" do
    it "returns true if the user's ID is in the config" do
      Lita.config.robot.admins = "1"
      expect(described_class.user_is_admin?(user)).to be_true
    end

    it "returns false if the user's ID is not in the config" do
      Lita.config.robot.admins = nil
      expect(described_class.user_is_admin?(user)).to be_false
    end
  end
end
