require "spec_helper"

describe Lita::Handler do
  let(:robot) { double("Lita::Robot", name: "Lita") }
  let(:user) { double("Lita::User") }

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

      def foo(response)
      end

      def blah(response)
      end

      def secret(response)
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
  end
end
