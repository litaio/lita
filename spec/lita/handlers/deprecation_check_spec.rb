require "spec_helper"

describe Lita::Handlers::DeprecationCheck, lita_handler: true do
  it { is_expected.to route_event(:loaded).to(:check_handlers_for_default_config) }

  describe "#check_handlers_for_default_config" do
    before do
      registry.register_handler(:foo) do
        def self.default_config(old_config)
          old_config.bar = :baz
        end
      end
    end

    it "logs a warning for handlers using the default_config method" do
      expect(Lita.logger).to receive(:warn).with(/found defined in the foo handler/)

      robot.trigger(:loaded, {})
    end
  end
end
