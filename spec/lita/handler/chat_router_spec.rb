require "spec_helper"

handler = Class.new do
  extend Lita::Handler::ChatRouter

  def self.name
    "Test"
  end

  route(/message/, :message)
  route(/command/, :command, command: true)
  route(/admin/, :admin, restrict_to: :admins)
  route(/error/, :error)
  route(/validate route hook/, :validate_route_hook, code_word: true)
  route(/trigger route hook/, :trigger_route_hook, custom_data: "trigger route hook")

  def message(response)
    response.reply("message")
  end

  def command(response)
    response.reply("command")
  end

  def admin(response)
    response.reply("admin")
  end

  def error(_response)
    raise
  end

  def validate_route_hook(response)
    response.reply("validate route hook")
  end

  def trigger_route_hook(response)
    response.reply(response.extensions[:custom_data])
  end

  route(/block/) do |response|
    response.reply("block")
  end
end

describe handler, lita_handler: true do
  describe ".dispatch" do
    it "routes a matching message to the supplied method" do
      send_message("message")
      expect(replies.last).to eq("message")
    end

    it "routes a matching message even if addressed to the robot" do
      send_command("message")
      expect(replies.last).to eq("message")
    end

    it "routes a command message to the supplied method" do
      send_command("command")
      expect(replies.last).to eq("command")
    end

    it "requires command routes to be addressed to the robot" do
      send_message("command")
      expect(replies).to be_empty
    end

    it "doesn't route messages that don't match anything" do
      send_message("nothing")
      expect(replies).to be_empty
    end

    it "dispatches to restricted routes if the user is in the auth group" do
      allow(robot.auth).to receive(:user_is_admin?).with(user).and_return(true)
      send_message("admin")
      expect(replies.last).to eq("admin")
    end

    it "doesn't route unauthorized users' messages to restricted routes" do
      send_message("admin")
      expect(replies).to be_empty
    end

    it "ignores messages from itself" do
      allow(user).to receive(:name).and_return(robot.name)
      send_message("message")
      expect(replies).to be_empty
    end

    it "allows route callbacks to be provided as blocks" do
      send_message("block")
      expect(replies.last).to eq("block")
    end

    it "logs exceptions without crashing" do
      test_mode = Lita.test_mode?

      begin
        Lita.test_mode = false
        expect(Lita.logger).to receive(:error).with(/Test crashed/)
        send_message("error")
      ensure
        Lita.test_mode = test_mode
      end
    end

    it "raises exceptions in test mode" do
      expect { send_message("error") }.to raise_error(RuntimeError)
    end

    context "with a custom validate_route hook" do
      let(:hook) do
        proc do |payload|
          if payload[:route].extensions[:code_word]
            payload[:message].body.include?("code word")
          else
            true
          end
        end
      end

      before { registry.register_hook(:validate_route, hook) }

      it "matches if the hook returns true" do
        send_message("validate route hook - code word")
        expect(replies.last).to eq("validate route hook")
      end

      it "does not match if the hook returns false" do
        send_message("validate route hook")
        expect(replies).to be_empty
      end
    end

    context "with a custom trigger_route hook" do
      let(:hook) do
        proc do |payload|
          payload[:response].extensions[:custom_data] = payload[:route].extensions[:custom_data]
        end
      end

      before { registry.register_hook(:trigger_route, hook) }

      it "adds data to the response's extensions" do
        send_message("trigger route hook")
        expect(replies.last).to eq("trigger route hook")
      end
    end
  end
end

handler = Class.new do
  extend Lita::Handler::ChatRouter
  extend Lita::Handler::EventRouter

  def self.name
    "Test"
  end

  route(/boom/) { |_response| 1 + "2" }

  route(/one/) { |response| response.reply "got one" }
  route(/two/) { |response| response.reply "got two" }

  on :unhandled_message do |payload|
    message = payload[:message]
    robot.send_message(message.source, message.body)
  end
end

describe handler, lita_handler: true do
  it "triggers the unhandled message event if no route matches" do
    send_message("this won't match any routes")
    expect(replies.last).to eq("this won't match any routes")
  end

  it "doesn't stop checking routes when the first one matches" do
    send_message("one two")
    expect(replies.last).to eq("got two")
  end

  context "with another handler registered" do
    before do
      registry.register_handler(:test_2)  do
        route(/three/)  { |response| response.reply "got three" }
      end
    end

    it "doesn't stop dispatching to handlers when there is a matching route in one" do
      send_message("two three")
      expect(replies.last).to eq("got three")
    end
  end

  context "when the handler raises an exception" do
    it "calls the error handler with the exception as argument" do
      expect(registry.config.robot.error_handler).to receive(:call).with(instance_of(TypeError))

      expect { send_message("boom!") }.to raise_error(TypeError)
    end
  end
end
