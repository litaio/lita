require "spec_helper"

describe Lita::ConfigurationValidator, lita: true do
  subject { described_class.new(registry) }

  describe "#call" do
    it "has no effect if there are no plugins registered configuration is valid" do
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

      expect { subject.call }.to raise_error(
        Lita::ValidationError,
        /Configuration attribute "foo" is required for "test" adapter/
      )
    end

    it "has no effect if all handlers have valid configuration" do
      registry.register_handler(:test) do
        config :foo, required: true, default: :bar
      end

      expect { subject.call }.not_to raise_error
    end

    it "raises if a required adapter configuration attribute is missing" do
      registry.register_handler(:test) do
        config :foo, required: true
      end

      expect { subject.call }.to raise_error(
        Lita::ValidationError,
        /Configuration attribute "foo" is required for "test" handler/
      )
    end
  end
end
