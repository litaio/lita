require "spec_helper"

describe Lita::Authorization, lita: true do
  let(:requesting_user) { instance_double("Lita::User", id: "1") }
  let(:user) { instance_double("Lita::User", id: "2") }

  subject { described_class.new(registry.config) }

  before do
    registry.config.robot.admins = ["1"]
  end

  describe "deprecated class methods" do
    {
      add_user_to_group: 3,
      remove_user_from_group: 3,
      user_in_group?: 2,
      user_is_admin?: 1,
      groups: 0,
      groups_with_users: 0
    }.each do |deprecated_method, arity|
      it "logs a warning and calls the instance method version of .#{deprecated_method}" do
        expect(Lita.logger).to receive(:warn).with(
          /Lita::Authorization\.#{Regexp.escape(deprecated_method)} will be removed in Lita 5\.0/
        )
        expect_any_instance_of(described_class).to receive(deprecated_method)
        described_class.public_send(deprecated_method, *arity.times.map { Object.new })
      end
    end
  end

  describe "#add_user_to_group" do
    it "adds users to an auth group" do
      subject.add_user_to_group(requesting_user, user, "employees")
      expect(subject.user_in_group?(user, "employees")).to be true
    end

    it "can only be called by admins" do
      registry.config.robot.admins = nil
      result = subject.add_user_to_group(
        requesting_user,
        user,
        "employees"
      )
      expect(result).to eq(:unauthorized)
      expect(subject.user_in_group?(user, "employees")).to be false
    end

    it "normalizes the group name" do
      subject.add_user_to_group(requesting_user, user, "eMPLoYeeS")
      expect(subject.user_in_group?(user, "  EmplOyEEs  ")).to be true
    end
  end

  describe "#remove_user_from_group" do
    it "removes users from an auth group" do
      subject.add_user_to_group(requesting_user, user, "employees")
      subject.remove_user_from_group(requesting_user, user, "employees")
      expect(subject.user_in_group?(user, "employees")).to be false
    end

    it "can only be called by admins" do
      subject.add_user_to_group(requesting_user, user, "employees")
      registry.config.robot.admins = nil
      result = subject.remove_user_from_group(
        requesting_user,
        user,
        "employees"
      )
      expect(result).to eq(:unauthorized)
      expect(subject.user_in_group?(user, "employees")).to be true
    end

    it "normalizes the group name" do
      subject.add_user_to_group(requesting_user, user, "eMPLoYeeS")
      subject.remove_user_from_group(requesting_user, user, "EmployeeS")
      expect(subject.user_in_group?(user, "  EmplOyEEs  ")).to be false
    end
  end

  describe "#user_in_group?" do
    it "returns false if the user is in the group" do
      expect(subject.user_in_group?(user, "employees")).to be false
    end

    it "delegates to .user_is_admin? if the group is admins" do
      expect(subject).to receive(:user_is_admin?)
      subject.user_in_group?(user, "admins")
    end
  end

  describe "#user_is_admin?" do
    it "returns true if the user's ID is in the config" do
      expect(subject.user_is_admin?(requesting_user)).to be true
    end

    it "returns false if the user's ID is not in the config" do
      registry.config.robot.admins = nil
      expect(subject.user_is_admin?(user)).to be false
    end
  end

  describe "#groups" do
    before do
      %i(foo bar baz).each do |group|
        subject.add_user_to_group(requesting_user, user, group)
      end
    end

    it "returns a list of all authorization groups" do
      expect(subject.groups).to match_array(%i(foo bar baz))
    end
  end

  describe "#groups_with_users" do
    before do
      %i(foo bar baz).each do |group|
        subject.add_user_to_group(requesting_user, user, group)
        subject.add_user_to_group(
          requesting_user,
          requesting_user,
          group
        )
      end
      allow(Lita::User).to receive(:find_by_id).with("1").and_return(requesting_user)
      allow(Lita::User).to receive(:find_by_id).with("2").and_return(user)
    end

    it "returns a hash of all authorization groups and their members" do
      groups = %i(foo bar baz)
      groups_with_users = subject.groups_with_users
      expect(groups_with_users.keys).to match_array(groups)
      groups.each do |group|
        expect(groups_with_users[group]).to match_array([user, requesting_user])
      end
    end
  end
end
