require "spec_helper"

handler_class = Class.new(Lita::Handler) do
  route(/^message$/, :message)
  route(/^command$/, :command, command: true)
  route("restricted", :restricted, restrict_to: :some_group)
  route("admins only", :admins_only, restrict_to: :admins)

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
  describe "routing messages" do
    it { is_expected.to route("message") }
    it { is_expected.to route("message").to(:message) }
    it { is_expected.not_to route("message").to(:not_a_message) }
  end

  describe "routing commands" do
    it { is_expected.to route_command("command") }
    it { is_expected.not_to route("command") }
    it { is_expected.not_to route_command("not a command") }
    it { is_expected.to route_command("command").to(:command) }
    it { is_expected.not_to route_command("command").to(:not_a_command) }
  end

  describe "routing to restricted routes" do
    it { is_expected.not_to route("restricted") }
    it { is_expected.to route("restricted").with_authorization_for(:some_group) }
    it { is_expected.not_to route("restricted").with_authorization_for(:wrong_group) }
    it { is_expected.to route("admins only").with_authorization_for(:admins) }
    it { is_expected.to route("restricted").with_authorization_for(:some_group).to(:restricted) }
    it { is_expected.not_to route("restricted").with_authorization_for(:some_group).to(:nothing) }
  end

  describe "routing HTTP routes" do
    it { is_expected.to route_http(:get, "web") }
    it { is_expected.to route_http(:get, "web").to(:web) }
    it { is_expected.not_to route_http(:get, "web").to(:message) }
    it { is_expected.not_to route_http(:post, "web") }
  end

  describe "routing events" do
    it { is_expected.to route_event(:connected) }
    it { is_expected.to route_event(:connected).to(:greet) }
    it { is_expected.not_to route_event(:not_an_event) }
    it { is_expected.not_to route_event(:connected).to(:message) }
  end

  describe "deprecated routing syntax" do
    before { allow(STDERR).to receive(:puts) }

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
