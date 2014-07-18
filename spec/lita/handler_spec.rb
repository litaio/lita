require "spec_helper"

describe Lita::Handler, lita: true do
  let(:robot) { instance_double("Lita::Robot", name: "Lita") }

  let(:queue) { Queue.new }

  let(:handler_class) do
    Class.new(described_class) do
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
