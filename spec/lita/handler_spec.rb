require "spec_helper"

describe Lita::Handler, lita_handler: true do
  before { registry.handlers.delete(described_class) }

  prepend_before(after_config: true) do
    registry.register_handler(:foo) do
      config :foo_response, required: true, type: String

      after_config do |config|
        route(/foo/) do |response|
          response.reply(config.foo_response)
        end
      end
    end
  end

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

  it "runs the after_config block configuration is finalized", after_config: true do
    registry.config.handlers.foo.foo_response = "baz"

    send_message("foo")

    expect(replies.last).to include("baz")
  end
end
