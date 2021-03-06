# frozen_string_literal: true

require "set"

require "i18n"
require "faraday"

require_relative "../adapters/test"
require_relative "../message"
require_relative "../rspec"
require_relative "../robot"
require_relative "../source"
require_relative "../user"
require_relative "matchers/chat_route_matcher"
require_relative "matchers/http_route_matcher"
require_relative "matchers/event_route_matcher"

module Lita
  module RSpec
    # Extras for +RSpec+ to facilitate testing Lita handlers.
    module Handler
      include Matchers::ChatRouteMatcher
      include Matchers::HTTPRouteMatcher
      include Matchers::EventRouteMatcher

      class << self
        # Sets up the RSpec environment to easily test Lita handlers.
        def included(base)
          base.include(Lita::RSpec)

          prepare_handlers(base)
          prepare_adapter(base)
          prepare_let_blocks(base)
          prepare_subject(base)
        end

        private

        # Register the test adapter.
        def prepare_adapter(base)
          base.class_eval do
            before do
              registry.register_adapter(:test, Lita::Adapters::Test)
              registry.config.robot.adapter = :test
            end
          end
        end

        # Register the handler(s) under test.
        def prepare_handlers(base)
          base.class_eval do
            before do
              handlers = Set.new(
                [described_class] + Array(base.metadata[:additional_lita_handlers])
              )

              handlers.each do |handler|
                registry.register_handler(handler)
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
      # @param as [User] The user sending the message.
      # @param from [Room] The room where the message is received from.
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
      # @param as [User] The user sending the message.
      # @param from [Room] The room where the message is received from.
      # @return [void]
      def send_command(body, as: user, from: nil, privately: false)
        send_message("#{robot.mention_name}: #{body}", as: as, from: from, privately: privately)
      end

      # Returns a Faraday connection hooked up to the currently running robot's Rack app.
      # @return [Faraday::Connection] The connection.
      # @since 4.0.0
      def http
        unless Rack.const_defined?(:Test)
          begin
            require "rack/test"
          rescue LoadError
            raise LoadError, I18n.t("lita.rspec.rack_test_required")
          end
        end

        Faraday::Connection.new { |c| c.adapter(:rack, robot.app) }
      end
    end
  end
end
