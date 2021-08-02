# frozen_string_literal: true

require "spec_helper"

describe Lita::Handlers::Help, lita_handler: true do
  it { is_expected.to route_command("help").to(:help) }
  it { is_expected.to route_command("help foo").to(:help) }

  describe "#help" do
    let(:dummy_handler_class) do
      Class.new(Lita::Handler) do
        def self.name
          "Dummy"
        end

        route(/secret/, :secret, restrict_to: :the_nobodies, help: {
          "secret" => "This help message should be accompanied by a caveat"
        })

        def secret(_response); end
      end
    end

    let(:dummy_handler_class_2) do
      Class.new(Lita::Handler) do
        def self.name
          "Dummy2"
        end

        namespace "Dummy"

        route(/foo/, :foo, help: { "foo" => "foo" })

        def foo(_response); end
      end
    end

    let(:another_handler) do
      Class.new(Lita::Handler) do
        def self.name
          "Another"
        end

        route(/bar dummy/, :bar, help: { "bar dummy" => "bar" })
        route(/baz/, :baz, help: { "baz" => "baz dummy" })

        def bar(_response); end

        def baz(_response); end
      end
    end

    before do
      registry.register_handler(dummy_handler_class)
      registry.register_handler(dummy_handler_class_2)
      registry.register_handler(another_handler)
      registry.config.robot.alias = "!"
    end

    it "lists all installed handlers in alphabetical order with duplicates removed" do
      send_command("help")
      expect(replies.last).to match(
        /^Send the message "!help QUERY".+installed:\n\nanother\ndummy\nhelp$/
      )
    end

    it "sends help information for all commands under a given handler" do
      send_command("help another")
      expect(replies.last).to match(/bar.+baz/m)
    end

    it "sends help information for all commands matching a given substring" do
      send_command("help foo")
      expect(replies.last).to match(/foo/)
    end

    it("sends help information for all relevant commands "\
      "when the given substring matches a handler + individual help messages") do
      send_command("help dummy")
      expect(replies.last).to match(/secret.+foo.+bar.+baz/m)
    end

    it "uses the mention name when no alias is defined" do
      allow(robot.config.robot).to receive(:alias).and_return(nil)
      send_command("help help")
      expect(replies.last).to match(/#{robot.mention_name}: help/)
    end

    it "responds with an error if the given substring has no matches" do
      send_command("help asdf")
      expect(replies.last).to eq("No matching handlers, message patterns, or descriptions found.")
    end

    it "doesn't crash if a handler doesn't have routes" do
      event_handler = Class.new do
        extend Lita::Handler::EventRouter
      end

      registry.register_handler(event_handler)

      expect { send_command("help") }.not_to raise_error
    end

    describe "restricted routes" do
      let(:authorized_user) do
        user = Lita::User.create(2, name: "Authorized User")
        Lita::Authorization.new(robot).add_user_to_group!(user, :the_nobodies)
        user
      end

      it "shows the unauthorized message for commands the user doesn't have access to" do
        send_command("help secret")
        expect(replies.last).to include("secret")
        expect(replies.last).to include("Unauthorized")
      end

      it "omits the unauthorized message if the user has access" do
        send_command("help secret", as: authorized_user)
        expect(replies.last).to include("secret")
        expect(replies.last).not_to include("Unauthorized")
      end
    end
  end
end
