require "spec_helper"

handler_class = Class.new(Lita::Handler) do
  route(/^message$/, :message)
  route(/^command$/, :command, command: true)
  route("restricted", :restricted, restrict_to: :some_group)

  http.get "web", :web

  on :connected, :greet

  def message(response)
    response.reply(response.user.name)
  end

  def command(response)
    response.reply("a", "command")
  end

  def restricted(_response)
  end

  def web(_request, _response)
  end

  def greet(_payload)
  end

  def self.name
    "Lita::Handlers::Test"
  end
end

describe handler_class, lita_handler: true do
  it { is_expected.to route("message") }
  it { is_expected.to route_command("command") }
  it { is_expected.not_to route("command") }
  it { is_expected.not_to route_command("not a command") }
  # TODO: it { is_expected.to route("restricted") }
  it { is_expected.to route_http(:get, "web") }
  it { is_expected.not_to route_http(:post, "web") }
  it { is_expected.to route_event(:connected) }
  it { is_expected.not_to route_event(:not_an_event) }

  describe "deprecated routing syntax" do
    it { routes("message").to(:message) }
    it { routes_command("command").to(:command) }
    it { doesnt_route("command").to(:command) }
    it { does_not_route("command").to(:command) }
    it { doesnt_route_command("not a command").to(:message) }
    it { does_not_route_command("not a command").to(:message) }
    it { routes("restricted").to(:restricted) }
    it { routes_http(:get, "web").to(:web) }
    it { doesnt_route_http(:post, "web").to(:web) }
    it { routes_event(:connected).to(:greet) }
    it { doesnt_route_event(:connected).to(:web) }
    it { does_not_route_event(:connected).to(:web) }
  end

  describe "#message" do
    it "replies with a string" do
      send_message("message")
      expect(replies).to eq(["Test User"])
    end
  end

  describe "#command" do
    it "replies with two strings" do
      send_command("command")
      expect(replies).to eq(%w(a command))
    end
  end

  it "allows the sending user to be specified" do
    another_user = Lita::User.create(2, name: "Another User")
    send_message("message", as: another_user)
    expect(replies.last).to eq("Another User")
  end
end
