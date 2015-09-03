require_relative "matchers/chat_route_matcher"
require_relative "matchers/http_route_matcher"
require_relative "matchers/event_route_matcher"
require_relative "matchers/deprecated"

module Lita
  module RSpec
    # Extras for +RSpec+ to facilitate testing Lita handlers.
    module Handler
      include Matchers::ChatRouteMatcher
      include Matchers::HTTPRouteMatcher
      include Matchers::EventRouteMatcher
      include Matchers::DeprecatedMethods

      class << self
        # Sets up the RSpec environment to easily test Lita handlers.
        def included(base)
          base.send(:include, Lita::RSpec)

          prepare_handlers(base)
          prepare_adapter(base)
          prepare_let_blocks(base)
          prepare_subject(base)
        end

        private

        # Stub Lita.adapters
        def prepare_adapter(base)
          base.class_eval do
            before do
              if Lita.version_3_compatibility_mode?
                Lita.config.robot.adapter = :test
              else
                registry.register_adapter(:test, Lita::Adapters::Test)
                registry.config.robot.adapter = :test
              end
            end
          end
        end

        # Stub Lita.handlers.
        def prepare_handlers(base)
          base.class_eval do
            before do
              handlers = Set.new(
                [described_class] + Array(base.metadata[:additional_lita_handlers])
              )

              if Lita.version_3_compatibility_mode?
                allow(Lita).to receive(:handlers).and_return(handlers)
              else
                handlers.each do |handler|
                  registry.register_handler(handler)
                end
              end
            end
          end
        end

        # Create common test objects.
        def prepare_let_blocks(base)
          base.class_eval do
            let(:robot) { Robot.new(registry) }
            let(:source) { Source.new(user: user) }
            let(:user) { User.create("1", name: "Test User") }
          end
        end

        # Set up a working test subject.
        def prepare_subject(base)
          base.class_eval do
            subject { described_class.new(robot) }
          end
        end
      end

      # An array of strings that have been sent by the robot during the course of a test.
      # @return [Array<String>] The replies.
      def replies
        robot.chat_service.sent_messages
      end

      # Sends a message to the robot.
      # @param body [String] The message to send.
      # @param as [Lita::User] The user sending the message.
      # @param from [Lita::Room] The room where the message is received from.
      # @return [void]
      def send_message(body, as: user, from: nil, privately: false)
        message = Message.new(
          robot,
          body,
          Source.new(user: as, room: from, private_message: privately)
        )

        robot.receive(message)
      end

      # Sends a "command" message to the robot.
      # @param body [String] The message to send.
      # @param as [Lita::User] The user sending the message.
      # @param from [Lita::Room] The room where the message is received from.
      # @return [void]
      def send_command(body, as: user, from: nil, privately: false)
        send_message("#{robot.mention_name}: #{body}", as: as, from: from, privately: privately)
      end

      # Returns a Faraday connection hooked up to the currently running robot's Rack app.
      # @return [Faraday::Connection] The connection.
      # @since 4.0.0
      def http
        begin
          require "rack/test"
        rescue LoadError
          raise LoadError, I18n.t("lita.rspec.rack_test_required")
        end unless Rack.const_defined?(:Test)

        Faraday::Connection.new { |c| c.adapter(:rack, robot.app) }
      end
    end
  end
end
