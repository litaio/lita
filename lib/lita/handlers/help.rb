# frozen_string_literal: true

module Lita
  # A namespace to hold all subclasses of {Handler}.
  module Handlers
    # Provides online help about Lita commands for users.
    class Help
      extend Handler::ChatRouter

      route(/^help\s*(?<substring>.+)?/i, :help, command: true, help: {
        "help"                   => t("help.help_value"),
        t("help.help_query_key") => t("help.help_query_value")
      })

      # Outputs help information about Lita commands.
      # @param response [Response] The response object.
      # @return [void]
      def help(response)
        substring = response.match_data["substring"]

        if substring.nil?
          return response.reply_privately(
            "#{t("help.info", address: address)}\n#{list_handlers.join("\n")}"
          )
        end

        handlers = matching_handlers(substring)
        handlers_to_messages = map_handlers_to_messages(response, handlers)
        messages = matching_messages(response, substring, handlers_to_messages)
        response.reply_privately(format_reply(handlers_to_messages, messages))
      end

      private

      # Checks if the user is authorized to at least one of the given groups.
      def authorized?(user, required_groups)
        required_groups.nil? || required_groups.any? do |group|
          robot.auth.user_in_group?(user, group)
        end
      end

      # Creates an alphabetically-sorted array containing the names of all
      # installed handlers.
      def list_handlers
        robot.handlers.flat_map do |handler|
          handler.namespace if handler.respond_to?(:routes)
        end.compact.uniq.sort
      end

      # Creates an array of handlers matching the given substring.
      def matching_handlers(substring)
        name = substring.downcase.strip

        return [] unless list_handlers.include?(name)

        robot.handlers.select { |handler| handler.namespace == name }
      end

      # Creates a hash of handler namespaces and their associated help messages.
      def map_handlers_to_messages(response, handlers)
        handlers_to_messages = {}
        handlers.each do |handler|
          messages = if handler.respond_to?(:routes)
            handler.routes.map do |route|
              route.help.map do |command, description|
                help_command(response, route, command, description)
              end
            end.flatten
          else
            []
          end

          (handlers_to_messages[handler.namespace] ||= []).push(*messages)
        end

        handlers_to_messages
      end

      # Creates an array of help messages for all registered routes.
      def all_help_messages(response)
        robot.handlers.map do |handler|
          next unless handler.respond_to?(:routes)

          handler.routes.map do |route|
            route.help.map do |command, description|
              help_command(response, route, command, description)
            end
          end
        end.flatten.compact
      end

      # Creates an array consisting of all help messages that match the given
      # substring.
      def all_matching_messages(response, substring)
        filter_messages(all_help_messages(response), substring)
      end

      # Removes matching help messages that are already present in the
      # comprehensive array of help messages defined by the requested
      # handler(s).
      def dedup_messages(handlers_to_messages, messages)
        all_handler_messages = handlers_to_messages.values.flatten
        messages.reject { |m| all_handler_messages.include?(m) }
      end

      # Creates an array of help messages matching the given substring, minus
      # duplicates.
      def matching_messages(response, substring, handlers_to_messages)
        dedup_messages(handlers_to_messages, all_matching_messages(response, substring))
      end

      # Filters help messages matching a substring.
      def filter_messages(messages, substring)
        messages.select do |line|
          /(?:@?#{Regexp.escape(address)})?#{Regexp.escape(substring)}/i.match?(line)
        end
      end

      # Formats a block of text associating a handler namespace with the help
      # messages it defines.
      def format_handler_messages(handler, messages)
        unless messages.empty?
          "#{t("help.handler_contains", handler: handler)}:\n" + messages.join("\n")
        end
      end

      # Formats the message to be sent in response to a help command.
      def format_reply(handlers_to_messages, messages)
        return t("help.no_help_found") if handlers_to_messages.empty? && messages.empty?

        handler_messages = handlers_to_messages.keys.map do |handler|
          format_handler_messages(handler, handlers_to_messages[handler])
        end.compact
        separator = handler_messages.empty? || messages.empty? ? "" : "\n\n"
        [handler_messages, messages].map { |m| m.join("\n") }.join(separator)
      end

      # Formats an individual command's help message.
      def help_command(response, route, command, description)
        command = "#{address}#{command}" if route.command?
        message = "#{command} - #{description}"
        message << t("help.unauthorized") unless authorized?(response.user, route.required_groups)
        message
      end

      # The way the bot should be addressed in order to trigger a command.
      def address
        robot.config.robot.alias || "#{name}: "
      end

      # Fallback in case no alias is defined.
      def name
        robot.config.robot.mention_name || robot.config.robot.name
      end
    end

    Lita.register_handler(Help)
  end
end
