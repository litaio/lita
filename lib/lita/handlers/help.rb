module Lita
  module Handlers
    class Help < Handler
      route(/^help\s*(.+)?/, to: :help, command: true, help: {
        "help" => "Lists help information for terms and command the robot will respond to.",
        "help COMMAND" => "Lists help information for terms or commands that begin with COMMAND."
      })

      def help(matches)
        output = []

        Lita.handlers.each do |handler|
          handler.routes.each do |route|
            route.help.each do |command, description|
              command = "#{name}: #{command}" if route.command?
              output << "#{command} - #{description}"
            end
          end
        end

        filter = matches[0][0]
        if filter
          output.select! { |line| /(?:@?#{name}[:,]?)?#{filter}/i === line }
        end

        reply output.join("\n")
      end

      private

      def name
        Lita.config.robot.mention_name || Lita.config.robot.name
      end
    end

    Lita.register_handler(Help)
  end
end
