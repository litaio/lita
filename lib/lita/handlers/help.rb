module Lita
  module Handlers
    # Provides online help about Lita commands for users.
    class Help < Handler
      route(/^help\s*(.+)?/, :help, command: true, help: {
        "help" => %{
Lists help information for terms and command the robot will respond to.
}.gsub(/\n/, ""),
        "help COMMAND" => %{
Lists help information for terms or commands that begin with COMMAND.
}.gsub(/\n/, "")
      })

      # Outputs help information about Lita commands.
      # @param response [Lita::Response] The response object.
      # @return [void]
      def help(response)
        output = build_help(response)
        output = filter_help(output, response)
        response.reply output.join("\n")
      end

      private

      # Checks if the user is authorized to at least one of the given groups.
      def authorized?(user, required_groups)
        required_groups.nil? || required_groups.any? do |group|
          Lita::Authorization.user_in_group?(user, group)
        end
      end

      # Creates an array of help info for all registered routes.
      def build_help(response)
        output = []

        Lita.handlers.each do |handler|
          handler.routes.each do |route|
            route.help.each do |command, description|
              next unless authorized?(response.user, route.required_groups)
              command = "#{name}: #{command}" if route.command?
              output << "#{command} - #{description}"
            end
          end
        end

        output
      end

      # Filters the help output by an optional command.
      def filter_help(output, response)
        filter = response.matches[0][0]

        if filter
          output.select { |line| /(?:@?#{name}[:,]?)?#{filter}/i === line }
        else
          output
        end
      end

      # The way the bot should be addressed in order to trigger a command.
      def name
        Lita.config.robot.mention_name || Lita.config.robot.name
      end
    end

    Lita.register_handler(Help)
  end
end
