require "spec_helper"

describe Lita::Handler, lita: true do
  let(:robot) { instance_double("Lita::Robot", name: "Lita") }
  let(:user) { instance_double("Lita::User", name: "Test User") }

  let(:message) do
    message = instance_double("Lita::Message", user: user, command?: false)
    allow(message).to receive(:match)
    message
  end

  let(:queue) { Queue.new }

  let(:guard_hook) do
    Class.new do
      def self.call(payload)
        if payload[:route][:options][:guard]
          payload[:message].body.include?("code word")
        else
          true
        end
      end
    end
  end

  let(:response_hook) do
    Class.new do
      def self.call(payload)
        payload[:response].extensions[:foo] = :bar
      end
    end
  end

  let(:handler_class) do
    Class.new(described_class) do
      route(/\w{3}/, :foo)
      route(/\w{4}/, :blah, command: true)
      route(/secret/, :secret, restrict_to: :admins)
      route(/danger/, :danger)
      route(/guard/, :guard, guard: true)

      on :connected, :greet
      on :some_hook, :test_payload

      def self.default_config(config)
        config.foo = "bar"
      end

      def foo(_response)
      end

      def blah(_response)
      end

      def secret(_response)
      end

      def danger(_response)
        raise "The developer of this handler's got a bug in their code!"
      end

      def guard(_response)
      end

      def greet(payload)
        robot.send_message("Hi, #{payload[:name]}! Lita has started!")
      end

      def after_test(_response, queue)
        after(2) { queue.push("Waited 2 seconds!") }
      end

      def every_test(_response, queue)
        array = [1, 2, 3]

        every(2) do |timer|
          value = array.shift

          if value
            queue.push(value)
          else
            timer.stop
          end
        end
      end

      def infinite_every_test(response)
        thread = every(5) { "Looping forever!" }
        response.reply("Replying after timer!")
        thread
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
      expect(Lita.logger).to receive(:error).with(/Lita::Handlers::Test crashed/)
      expect { handler_class.dispatch(robot, message) }.not_to raise_error
    end

    it "re-raises exceptions when testing with RSpec" do
      allow(message).to receive(:body).and_return("#{robot.name}: danger")
      expect { handler_class.dispatch(robot, message) }.to raise_error
    end

    context "with a custom validate_route hook" do
      before { Lita.register_hook(:validate_route, guard_hook) }
      after { Lita.reset_hooks }

      it "matches if the hook returns true" do
        allow(message).to receive(:body).and_return("guard code word")
        expect_any_instance_of(handler_class).to receive(:guard)
        handler_class.dispatch(robot, message)
      end

      it "does not match if the hook returns false" do
        allow(message).to receive(:body).and_return("guard")
        expect_any_instance_of(handler_class).not_to receive(:guard)
        handler_class.dispatch(robot, message)
      end
    end

    context "with a custom trigger_route hook" do
      before { Lita.register_hook(:trigger_route, response_hook) }
      after { Lita.reset_hooks }

      it "adds data to the response's extensions" do
        allow(message).to receive(:body).and_return("foo")
        allow_any_instance_of(handler_class).to receive(:foo) do |_robot, response|
          expect(response.extensions[:foo]).to eq(:bar)
        end
        handler_class.dispatch(robot, message)
      end
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

  describe ".trigger" do
    it "invokes methods registered with .on and passes an arbitrary payload" do
      expect(robot).to receive(:send_message).with(
        "Hi, Carl! Lita has started!"
      )
      handler_class.trigger(robot, :connected, name: "Carl")
    end

    it "normalizes the event name" do
      expect(robot).to receive(:send_message).twice
      handler_class.trigger(robot, "connected")
      handler_class.trigger(robot, " ConNected  ")
    end
  end

  describe "#config" do
    before { Lita.register_handler(handler_class) }
    subject { handler_class.new(robot) }

    it "returns a Lita config" do
      expect(subject.config).to be_a(Lita::Config)
    end

    it "contains the handler's config settings" do
      expect(subject.config.foo).to eq("bar")
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

  describe "#log" do
    it "returns the Lita logger" do
      expect(subject.log).to eq(Lita.logger)
    end
  end

  describe "timer methods" do
    let(:response) { instance_double("Lita::Response") }

    subject { handler_class.new(robot) }

    before { allow_any_instance_of(Lita::Timer).to receive(:sleep) }

    describe "#after" do
      it "triggers the block after the given number of seconds" do
        subject.after_test(response, queue)
        expect(queue.pop).to eq("Waited 2 seconds!")
        expect { queue.pop(true) }.to raise_error(ThreadError)
      end
    end

    describe "#every" do
      it "triggers the block until the timer is stopped" do
        subject.every_test(response, queue)
        expect(queue.pop).to eq(1)
        expect(queue.pop).to eq(2)
        expect(queue.pop).to eq(3)
        expect { queue.pop(true) }.to raise_error(ThreadError)
      end
    end

    context "with an infinite timer" do
      it "doesn't block the handler's thread" do
        expect(response).to receive(:reply)
        thread = subject.infinite_every_test(response)
        thread.kill
      end
    end
  end
end
