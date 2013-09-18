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

      http.get "/lita/help", :web_help

      # Outputs help information about Lita commands.
      # @param response [Lita::Response] The response object.
      # @return [void]
      def help(response)
        output = build_help(response)
        output = filter_help(output, response)

        if Lita.config.robot.help_url_prefix
          response.reply_privately <<-REPLY.chomp
View the list of commands at #{Lita.config.robot.help_url_prefix}/lita/help
REPLY
        else
          response.reply_privately output.join("\n")
        end
      end

      # Provides a formatted HTML page listing available chat commands.
      #
      # @note If you want all +help+ requests to be given a URL with
      #   a list of commands rather than listing them within the chat
      #   then you must specify the publicly accessible URL for your
      #   chat bot using +Lita.config.robot.help_url_prefix+ within
      #   +lita_config.rb+
      #
      # @example Sample configuration
      #   # lita_config.rb
      #   Lita.configure do |config|
      #     ...
      #     config.robot.help_url_prefix = "http://my-lita-bot.herokuapp.com"
      #     ...
      #   end
      #
      # @param request [Rack::Request] The request object.
      # @param response [Rack::Response] The response object.
      # @return [void]
      def web_help(request, response)
        response.headers["Content-Type"] = "text/html"
        gem_dir = File.dirname(File.expand_path(__FILE__))
        template_file = File.join gem_dir, 'help.html.erb'
        response.write ERB.new(File.read(template_file)).result
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
