require "spec_helper"

describe Lita::Handler::EventRouter do
  let(:robot) { instance_double("Lita::Robot", name: "Lita") }

  subject do
    Class.new do
      extend Lita::Handler::EventRouter

      def self.name
        "Test"
      end

      on :connected, :greet

      def greet(payload)
        robot.send_message("Hi, #{payload[:name]}! Lita has started!")
      end
    end
  end

  describe ".trigger" do
    it "invokes methods registered with .on and passes an arbitrary payload" do
      expect(robot).to receive(:send_message).with(
        "Hi, Carl! Lita has started!"
      )
      subject.trigger(robot, :connected, name: "Carl")
    end

    it "normalizes the event name" do
      expect(robot).to receive(:send_message).twice
      subject.trigger(robot, "connected")
      subject.trigger(robot, " ConNected  ")
    end
  end
end
