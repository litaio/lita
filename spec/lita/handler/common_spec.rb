require "spec_helper"

describe Lita::Handler::Common, lita: true do
  let(:robot) { Lita::Robot.new(registry) }

  let(:handler) do
    Class.new do
      include Lita::Handler::Common

      namespace "foo"
    end
  end

  subject { handler.new(robot) }

  describe ".config" do
    it "sets configuration attributes" do
      handler.config :foo

      config = handler.configuration_builder.build

      expect(config.foo).to be_nil
      config.foo = :bar
      expect(config.foo).to eq(:bar)
    end
  end

  describe ".configuration_builder" do
    it "returns a ConfigurationBuilder object" do
      expect(handler.configuration_builder).to be_a(Lita::ConfigurationBuilder)
    end

    it "is memoized" do
      expect(handler.configuration_builder).to equal(handler.configuration_builder)
    end
  end

  describe ".namespace" do
    it "returns a snake cased namesapce for the handler based on class name" do
      handler = Class.new do
        include Lita::Handler::Common

        def self.name
          "Lita::Handlers::FooBarBaz"
        end
      end

      expect(handler.namespace).to eq("foo_bar_baz")
    end

    it "allows the namespace to be set with a simple string" do
      handler = Class.new do
        include Lita::Handler::Common

        namespace "common"
      end

      expect(handler.namespace).to eq("common")
    end

    it "allows the namespace to be set with the full path to an object as a string" do
      handler = Class.new do
        include Lita::Handler::Common

        namespace "Lita::Handler::Common"
      end

      expect(handler.namespace).to eq("common")
    end

    it "allows the namespace to be set with an object" do
      handler = Class.new do
        include Lita::Handler::Common

        namespace Lita::Handler::Common
      end

      expect(handler.namespace).to eq("common")
    end

    it "raises an exception if the handler doesn't have a name to derive the namespace from" do
      handler = Class.new { include Lita::Handler::Common }
      expect { handler.namespace }.to raise_error
    end
  end

  describe "#config" do
    before { registry.register_handler(handler) }

    context "with old-style config" do
      let(:handler) do
        Class.new do
          include Lita::Handler::Common

          namespace "foo_bar_baz"

          def self.default_config(config)
            config.style = :old
          end
        end
      end

      it "returns the handler's config settings" do
        expect(subject.config.style).to eq(:old)
      end
    end

    context "with new-style config" do
      let(:handler) do
        Class.new do
          include Lita::Handler::Common

          namespace "foo_bar_baz"

          config :style, default: :new
        end
      end

      it "returns the handler's config settings" do
        expect(subject.config.style).to eq(:new)
      end
    end

    context "with both types of configuration" do
      let(:handler) do
        Class.new do
          include Lita::Handler::Common

          namespace "foo_bar_baz"

          config :style, default: :new

          def self.default_config(config)
            config.style = :old
          end
        end
      end

      it "gives precedence to the new style" do
        expect(subject.config.style).to eq(:new)
      end
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

  describe "#render_template" do
    context "with the template root set" do
      before do
        handler.template_root(File.expand_path(File.join("..", "..", "..", "templates"), __FILE__))
      end

      it "renders the given template to a string" do
        expect(subject.render_template("basic")).to eq("Template rendered from a file!")
      end

      it "interpolates variables into the rendered template" do
        result = subject.render_template("interpolated", first: "Carl", last: "Pug")

        expect(result).to eq("I love Carl Pug!")
      end

      it "renders adapter-specific templates if available" do
        robot.config.robot.adapter = :irc
        expect(subject.render_template("basic")).to eq("IRC template rendered from a file!")
      end
    end

    it "raises an exception if the template root hasn't been set" do
      expect { subject.render_template("basic") }.to raise_error(Lita::MissingTemplateRootError)
    end
  end

  describe "timer methods" do
    let(:queue) { Queue.new }

    subject { handler.new(robot) }

    before { allow_any_instance_of(Lita::Timer).to receive(:sleep) }

    describe "#after" do
      let(:handler) do
        Class.new do
          include Lita::Handler::Common

          namespace "foo"

          def after_test(queue)
            after(2) { queue.push("Waited 2 seconds!") }
          end
        end
      end

      it "triggers the block after the given number of seconds" do
        subject.after_test(queue)
        expect(queue.pop).to eq("Waited 2 seconds!")
        expect { queue.pop(true) }.to raise_error(ThreadError)
      end
    end

    describe "#every" do
      let(:handler) do
        Class.new do
          include Lita::Handler::Common

          namespace "foo"

          def every_test(queue)
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
        end
      end

      it "triggers the block until the timer is stopped" do
        subject.every_test(queue)
        expect(queue.pop).to eq(1)
        expect(queue.pop).to eq(2)
        expect(queue.pop).to eq(3)
        expect { queue.pop(true) }.to raise_error(ThreadError)
      end
    end

    context "with an infinite timer" do
      let(:response) { instance_double("Lita::Response") }

      let(:handler) do
        Class.new do
          include Lita::Handler::Common

          namespace "foo"

          def infinite_every_test(response)
            thread = every(5) { "Looping forever!" }
            response.reply("Replying after timer!")
            thread
          end
        end
      end

      it "doesn't block the handler's thread" do
        expect(response).to receive(:reply)
        thread = subject.infinite_every_test(response)
        thread.kill
      end
    end
  end
end
