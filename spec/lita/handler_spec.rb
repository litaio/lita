require "spec_helper"

describe Lita::Handler, lita_handler: true do
  before { registry.handlers.delete(described_class) }

  it "includes chat routes" do
    registry.register_handler(:foo) do
      route(/foo/) do |response|
        response.reply("bar")
      end
    end

    send_message("foo")

    expect(replies.last).to include("bar")
  end

  it "includes HTTP routes" do
    registry.register_handler(:foo) do
      http.get "foo" do |_request, response|
        response.write("bar")
      end
    end

    http_client = Faraday::Connection.new { |c| c.adapter(:rack, Lita::RackApp.new(robot)) }
    response = http_client.get("/foo")

    expect(response.body).to eq("bar")
  end

  it "includes event routes" do
    registry.register_handler(:foo) do
      on(:some_event) { robot.send_message("payload received") }
    end

    expect(robot).to receive(:send_message).with("payload received")

    robot.trigger(:some_event)
  end
end
