require "spec_helper"

describe Lita::Handlers::Users, lita_handler: true do
  it { is_expected.to route_command("users find carl").to(:find) }

  describe "#find" do
    it "finds users by ID" do
      send_command("users find 1")

      expect(replies.first).to eq("Test User (ID: 1, Mention name: Test User)")
    end

    it "finds users by name" do
      send_command("users find 'Test User'")

      expect(replies.first).to eq("Test User (ID: 1, Mention name: Test User)")
    end

    it "finds users by mention name" do
      Lita::User.create(2, name: "Mr. Pug", mention_name: "carl")

      send_command("users find carl")

      expect(replies.first).to eq("Mr. Pug (ID: 2, Mention name: carl)")
    end

    it "replies with a message when no matches are found" do
      send_command("users find nobody")

      expect(replies.first).to eq("No matching users found.")
    end
  end
end
