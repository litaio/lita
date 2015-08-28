require "spec_helper"

describe Lita::Handler::EventRouter, lita: true do
  let(:robot) { Lita::Robot.new(registry) }

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

      on :callable_test, lambda { |payload|
        robot.send_message("#{payload[:data]} received via callable!")
      }

      on(:multiple_callbacks) { robot.send_message("first callback") }
      on(:multiple_callbacks) { robot.send_message("second callback") }

      on(:multiple_errors) do
        robot.send_message("first error")
        raise ArgumentError, "first"
      end

      on(:multiple_errors) do
        robot.send_message("second error")
        raise ArgumentError, "second"
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

    it "calls blocks that were passed to .on" do
      expect(robot).to receive(:send_message).with("Data received via block!")
      subject.trigger(robot, :block_test, data: "Data")
    end

    it "calls arbitrary callables that were passed to .on" do
      expect(robot).to receive(:send_message).with("Data received via callable!")
      subject.trigger(robot, :callable_test, data: "Data")
    end

    it "doesn't stop triggering callbacks after the first is triggered" do
      allow(robot).to receive(:send_message)

      expect(robot).to receive(:send_message).with("second callback")

      subject.trigger(robot, :multiple_callbacks)
    end

    it "normalizes the event name" do
      expect(robot).to receive(:send_message).twice
      subject.trigger(robot, "connected")
      subject.trigger(robot, " ConNected  ")
    end

    context "not in test mode" do
      around do |example|
        test_mode = Lita.test_mode?
        Lita.test_mode = false
        begin
          example.run
        ensure
          Lita.test_mode = test_mode
        end
      end

      it "doesn't stop triggering callbacks after an exception is raised" do
        expect(robot).to receive(:send_message).with("first error").once
        expect(robot).to receive(:send_message).with("second error").once
        subject.trigger(robot, :multiple_errors)
      end

      it "reports callback exceptions to the error handler" do
        allow(robot).to receive(:send_message)
        expect(registry.config.robot.error_handler).to receive(:call).twice
        subject.trigger(robot, :multiple_errors)
      end
    end

    context "in test mode" do
      around do |example|
        test_mode = Lita.test_mode?
        Lita.test_mode = true
        begin
          example.run
        ensure
          Lita.test_mode = test_mode
        end
      end

      it "re-raises callback exceptions immediately" do
        allow(robot).to receive(:send_message)
        expect(registry.config.robot.error_handler).to receive(:call).once
        expect { subject.trigger(robot, :multiple_errors) }.to raise_error(ArgumentError, "first")
      end
    end
  end
end
