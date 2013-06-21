require "spec_helper"

describe Lita::Handlers::Help, lita: true do
  it { routes("#{robot.name}: help").to(:help) }
  it { routes("#{robot.name}: help foo").to(:help) }

  describe "#help" do
    it "sends help information for all commands" do
      expect_reply(/help - Lists.+help COMMAND - Lists/m)
      send_test_message("#{robot.name}: help")
    end

    it "sends help information for commands starting with COMMAND" do
      expect_reply(/help COMMAND - Lists/)
      expect_no_reply(/help - Lists/)
      send_test_message("#{robot.name}: help help command")
    end
  end
end
