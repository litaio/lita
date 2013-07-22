require "spec_helper"

describe Lita::Handler, lita: true do
  let(:robot) { double("Lita::Robot", name: "Lita") }
  let(:user) { double("Lita::User", name: "Test User") }

  let(:message) do
    message = double("Lita::Message", user: user, command?: false)
    allow(message).to receive(:match)
    message
  end

  let(:handler_class) do
    Class.new(described_class) do
      route(/\w{3}/, :foo)
      route(/\w{4}/, :blah, command: true)
      route(/secret/, :secret, restrict_to: :admins)
      route(/danger/, :danger)

      http.get "web", :web

      def foo(response)
      end

      def blah(response)
      end

      def secret(response)
      end

      def web(request, response)
      end

      def danger(response)
        raise "The developer of this handler's got a bug in their code!"
      end

      def self.name
        "Lita::Handlers::Test"
      end
    end
  end

  subject { described_class.new(robot) }

  describe ".dispatch" do
    it "routes a matching message to the supplied method" do
      allow(message).to receive(:body).and_return("bar")
      expect_any_instance_of(handler_class).to receive(:foo)
      handler_class.dispatch(robot, message)
    end

    it "routes a matching message even if addressed to the Robot" do
      allow(message).to receive(:body).and_return("#{robot.name}: bar")
      allow(message).to receive(:command?).and_return(true)
      expect_any_instance_of(handler_class).to receive(:foo)
      handler_class.dispatch(robot, message)
    end

    it "routes a command message to the supplied method" do
      allow(message).to receive(:body).and_return("#{robot.name}: bar")
      allow(message).to receive(:command?).and_return(true)
      expect_any_instance_of(handler_class).to receive(:blah)
      handler_class.dispatch(robot, message)
    end

    it "requires command routes to be addressed to the Robot" do
      allow(message).to receive(:body).and_return("blah")
      expect_any_instance_of(handler_class).not_to receive(:blah)
      handler_class.dispatch(robot, message)
    end

    it "doesn't route messages that don't match anything" do
      allow(message).to receive(:body).and_return("yo")
      expect_any_instance_of(handler_class).not_to receive(:foo)
      expect_any_instance_of(handler_class).not_to receive(:blah)
      handler_class.dispatch(robot, message)
    end

    it "dispatches to restricted routes if the user is in the auth group" do
      allow(message).to receive(:body).and_return("secret")
      allow(Lita::Authorization).to receive(:user_in_group?).and_return(true)
      expect_any_instance_of(handler_class).to receive(:secret)
      handler_class.dispatch(robot, message)
    end

    it "doesn't route unauthorized users' messages to restricted routes" do
      allow(message).to receive(:body).and_return("secret")
      allow(Lita::Authorization).to receive(:user_in_group?).and_return(false)
      expect_any_instance_of(handler_class).not_to receive(:secret)
      handler_class.dispatch(robot, message)
    end
    
    it "doesn't route messages from the bot back to the bot" do
      allow(message).to receive(:body).and_return("#{robot.name}: bar")
      allow(message).to receive(:command?).and_return(true)
      allow(message).to receive(:user).and_return(robot)
      expect_any_instance_of(handler_class).not_to receive(:blah)
      handler_class.dispatch(robot, message)
    end

    it "logs exceptions but doesn't crash the bot" do
      allow(message).to receive(:body).and_return("#{robot.name}: danger")
      allow(handler_class).to receive(:rspec_loaded?).and_return(false)
      expect(Lita.logger).to receive(:error).with(
        %r{Lita::Handlers::Test crashed}
      )
      expect { handler_class.dispatch(robot, message) }.not_to raise_error
    end

    it "re-raises exceptions when testing with RSpec" do
      allow(message).to receive(:body).and_return("#{robot.name}: danger")
      expect { handler_class.dispatch(robot, message) }.to raise_error
    end
  end

  describe ".namespace" do
    it "provides a snake cased namespace for the handler" do
      handler_class = Class.new(described_class) do
        def self.name
          "Lita::Handlers::FooBarBaz"
        end
      end
      expect(handler_class.namespace).to eq("foo_bar_baz")
    end

    it "raises an exception if the handler doesn't define self.name" do
      handler_class = Class.new(described_class)
      expect { handler_class.namespace }.to raise_error
    end
  end

  describe "#http" do
    it "returns a Faraday connection" do
      expect(subject.http).to be_a(Faraday::Connection)
    end

    it "sets a default user agent" do
      expect(subject.http.headers["User-Agent"]).to eq("Lita v#{Lita::VERSION}")
    end

    it "merges in user-supplied options" do
      connection = subject.http(headers: {
        "User-Agent" => "Foo", "X-Bar" => "Baz"
      })
      expect(connection.headers["User-Agent"]).to eq("Foo")
      expect(connection.headers["X-Bar"]).to eq("Baz")
    end

    it "passes blocks on to Faraday" do
      connection = subject.http { |builder| builder.response :logger }
      expect(connection.builder.handlers).to include(Faraday::Response::Logger)
    end
  end
end
