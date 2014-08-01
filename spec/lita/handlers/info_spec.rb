require "spec_helper"

describe Lita::Handlers::Info, lita_handler: true do
  it { is_expected.to route_command("info").to(:chat) }
  it { is_expected.to route_http(:get, "/lita/info").to(:web) }

  let(:request) { double("Rack::Request") }
  let(:response) { Rack::Response.new }

  describe "#chat" do
    it "responds with the current version of Lita" do
      send_command("info")
      expect(replies.first).to include(Lita::VERSION)
    end

    it "responds with a link to the website" do
      send_command("info")
      expect(replies.first).to include("lita.io")
    end

    it "responds with the Redis version and memory usage" do
      send_command("info")
      expect(replies.last).to match(/Redis [\d\.]+ - Memory used: [\d\.]+[BKMG]/)
    end
  end

  describe "#web" do
    let(:json) { MultiJson.load(response.body.join) }

    it "returns JSON" do
      subject.web(request, response)
      expect(response.headers["Content-Type"]).to eq("application/json")
    end

    it "includes the current version of Lita" do
      subject.web(request, response)
      expect(json).to include("lita_version" => Lita::VERSION)
    end

    it "includes the adapter being used" do
      subject.web(request, response)
      expect(json).to include("adapter" => Lita.config.robot.adapter.to_s)
    end

    it "includes the robot's name" do
      subject.web(request, response)
      expect(json).to include("robot_name" => robot.name)
    end

    it "includes the robot's mention name" do
      subject.web(request, response)
      expect(json).to include("robot_mention_name" => robot.mention_name)
    end

    it "includes the Redis version" do
      subject.web(request, response)
      expect(json).to have_key("redis_version")
    end

    it "includes the Redis memory usage" do
      subject.web(request, response)
      expect(json).to have_key("redis_memory_usage")
    end
  end
end
