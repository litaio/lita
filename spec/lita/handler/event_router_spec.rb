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

      on :block_test do |payload|
        robot.send_message("#{payload[:data]} received via block!")
      end

      # TODO: Add example with arbitrary callable.
    end
  end

  describe ".trigger" do
    it "invokes methods registered with .on and passes an arbitrary payload" do
      expect(robot).to receive(:send_message).with(
        "Hi, Carl! Lita has started!"
      )
      subject.trigger(robot, :connected, name: "Carl")
    end

    it "calls blocks that were passed to .on" do
      expect(robot).to receive(:send_message).with("Data received via block!")
      subject.trigger(robot, :block_test, data: "Data")
    end

    it "normalizes the event name" do
      expect(robot).to receive(:send_message).twice
      subject.trigger(robot, "connected")
      subject.trigger(robot, " ConNected  ")
    end
  end
end
