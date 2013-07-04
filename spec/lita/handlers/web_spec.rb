require "spec_helper"

describe Lita::Handlers::Web, lita_handler: true do
  it { routes_http(:get, "/lita/info").to(:info) }
  it { doesnt_route_http(:post, "/lita/info").to(:info) }

  let(:request) { double("Rack::Request") }
  let(:response) { Rack::Response.new }

  describe "#info" do
    it "returns JSON with info about the running robot" do
      subject.info(request, response)
      expect(response.headers["Content-Type"]).to eq("application/json")
      expect(response.body.join).to include(
        %{"lita_version":"#{Lita::VERSION}"}
      )
    end
  end
end
