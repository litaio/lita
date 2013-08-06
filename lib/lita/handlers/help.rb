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
        output = []

        Lita.handlers.each do |handler|
          handler.routes.each do |route|
            route.help.each do |command, description|
              command = "#{name}: #{command}" if route.command?
              output << "#{command} - #{description}"
            end
          end
        end

        filter = response.matches[0][0]
        if filter
          output.select! { |line| /(?:@?#{name}[:,]?)?#{filter}/i === line }
        end

        response.reply output.join("\n")
      end

      private

      # The way the bot should be addressed in order to trigger a command.
      def name
        Lita.config.robot.mention_name || Lita.config.robot.name
      end
    end

    Lita.register_handler(Help)
  end
end
