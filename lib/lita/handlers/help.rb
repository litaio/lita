module Lita
  module Handlers
    class Help < Handler
      route(/^help\s*(.+)?/, to: :help, command: true)

      def self.help
        robot_name = Lita.config.robot.name

        {
          "#{robot_name}: help" => "Lists help information for terms and commands #{robot_name} will respond to.",
          "#{robot_name}: help COMMAND" => "Lists help information for terms and commands starting with COMMAND."
        }
      end

      def help(matches)
        commands = {}

        Lita.handlers.each do |handler|
          commands.merge!(handler.help) if handler.respond_to?(:help)
        end

        filter = matches[0][0]
        if filter
          robot_name = Lita.config.robot.name
          commands.select! do |key, value|
            /^#{filter}/i === key.sub(/^\s*@?#{robot_name}[:,]?\s*/, "")
          end
        end

        message = commands.map do |command, description|
          "#{command} - #{description}"
        end.join("\n")

        reply message
      end
    end

    Lita.register_handler(Help)
  end
end
