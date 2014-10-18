require "spec_helper"

describe Lita::ConfigurationValidator, lita: true do
  subject { described_class.new(registry) }

  describe "#call" do
    it "has no effect if there are no plugins registered" do
      expect { subject.call }.not_to raise_error
    end

    it "has no effect if all adapters have valid configuration" do
      registry.register_adapter(:test) do
        config :foo, required: true, default: :bar
      end

      expect { subject.call }.not_to raise_error
    end

    it "raises if a required adapter configuration attribute is missing" do
      registry.register_adapter(:test) do
        config :foo, required: true
      end

      expect(Lita.logger).to receive(:fatal).with(
        /Configuration attribute "foo" is required for "test" adapter/
      )
      expect { subject.call }.to raise_error(SystemExit)
    end

    it "has no effect if all adapters with nested configuration have valid configuration" do
      registry.register_adapter(:test) do
        config :foo do
          config :bar, required: true, default: :baz
        end
      end

      expect { subject.call }.not_to raise_error
    end

    it "raises if a required nested adapter configuration attribute is missing" do
      registry.register_adapter(:test) do
        config :foo do
          config :bar, required: true
        end
      end

      expect(Lita.logger).to receive(:fatal).with(
        /Configuration attribute "foo\.bar" is required for "test" adapter/
      )
      expect { subject.call }.to raise_error(SystemExit)
    end

    it "uses the right namespace for a nested attribute when a previous nesting has been visited" do
      registry.register_adapter(:test) do
        config :foo do
          config :bar
        end

        config :one do
          config :two, required: true
        end
      end

      expect(Lita.logger).to receive(:fatal).with(
        /Configuration attribute "one\.two" is required for "test" adapter/
      )
      expect { subject.call }.to raise_error(SystemExit)
    end

    it "has no effect if all handlers have valid configuration" do
      registry.register_handler(:test) do
        config :foo, required: true, default: :bar
      end

      expect { subject.call }.not_to raise_error
    end

    it "raises if a required handler configuration attribute is missing" do
      registry.register_handler(:test) do
        config :foo, required: true
      end

      expect(Lita.logger).to receive(:fatal).with(
        /Configuration attribute "foo" is required for "test" handler/
      )
      expect { subject.call }.to raise_error(SystemExit)
    end

    it "has no effect if all handlers with nested configuration have valid configuration" do
      registry.register_handler(:test) do
        config :foo do
          config :bar, required: true, default: :baz
        end
      end

      expect { subject.call }.not_to raise_error
    end

    it "raises if a required nested handler configuration attribute is missing" do
      registry.register_handler(:test) do
        config :foo do
          config :bar, required: true
        end
      end

      expect(Lita.logger).to receive(:fatal).with(
        /Configuration attribute "foo\.bar" is required for "test" handler/
      )
      expect { subject.call }.to raise_error(SystemExit)
    end
  end
end
