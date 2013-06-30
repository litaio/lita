require "spec_helper"

describe Lita::Handlers::Help, lita: true do
  it { routes("#{robot.name}: help").to(:help) }
  it { routes("#{robot.name}: help foo").to(:help) }

  describe "#help" do
    it "sends help information for all commands" do
      send_command("help")
      expect(replies.last).to match(
        /#{robot.mention_name}: help.+#{robot.mention_name}: help COMMAND/m
      )
    end

    it "sends help information for commands starting with COMMAND" do
      send_command("help help COMMAND")
      expect(replies.last).to match(/help COMMAND - Lists/)
      expect(replies.last).not_to match(/help - Lists/)
    end
  end
end
