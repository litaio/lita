require "spec_helper"

describe Lita::Handlers::Help, lita_handler: true do
  it { routes_command("help").to(:help) }
  it { routes_command("help foo").to(:help) }

  it { routes_http(:get, "/lita/help").to(:web_help) }

  describe "#help" do
    let(:secret_handler_class) do
      Class.new(Lita::Handler) do
        route(/secret/, :secret, restrict_to: :the_nobodies, help: {
          "secret" => "no one should ever see this help message"
        })
      end
    end
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

    it "doesn't show help for commands the user doesn't have access to" do
      allow(Lita).to receive(:handlers).and_return([
        described_class,
        secret_handler_class
      ])
      send_command("help")
      expect(replies.last).not_to include("secret")
    end
  end

  describe "#web_help" do
    it "ensures that calling help with the config option set works" do
      Lita.configure do |config|
        config.public_url = "http://litabot"
      end

      send_command("help")
      expect(replies.last).to match(/^View the list of commands at /)
      expect(replies.last).to match(/http:\/\/litabot\/lita\/help$/)
    end
  end
end
