require "spec_helper"

describe Lita::Handlers::Info, lita_handler: true do
  it { routes_command("info").to(:chat) }
  it { routes_http(:get, "/lita/info").to(:web) }

  let(:request) { double("Rack::Request") }
  let(:response) { Rack::Response.new }

  describe "#chat" do
    it "responds with the current version of Lita" do
      send_command("info")
      expect(replies.last).to include(Lita::VERSION)
    end

    it "responds with a link to the website" do
      send_command("info")
      expect(replies.last).to include("lita.io")
    end
  end

  describe "#web" do
    it "returns JSON with info about the running robot" do
      subject.web(request, response)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(response.body.join).to include(
        %{"lita_version":"#{Lita::VERSION}"}
      )
    end
  end
end
