require "logger"

module Lita
  # Creates a Logger with the proper configuration.
  # @api private
  module Logger
    class << self
      # Creates a new {::Logger} outputting to standard error with the given
      # severity level and a custom format.
      # @param level [Symbol, String] The name of the log level to use.
      # @param formatter [Proc] A proc to produce a custom log message format.
      # @param io [String, IO] Where to write the logs. When this value is a +String+, logs will be
      #   written to the named file. When this value is an +IO+, logs will be written to the +IO+.
      # @return [::Logger] The {::Logger} object.
      def get_logger(level, formatter = Lita.config.robot.log_formatter, io: STDERR)
        logger = ::Logger.new(io)
        logger.progname = "lita"
        logger.level = get_level_constant(level)
        logger.formatter = formatter if formatter
        logger
      end

      private

      # Gets the Logger constant for the given severity level.
      def get_level_constant(level)
        if level
          begin
            ::Logger.const_get(level.to_s.upcase)
          rescue NameError
            return ::Logger::INFO
          end
        else
          ::Logger::INFO
        end
      end
    end
  end
end
