module Lita
  # Creates a Logger with the proper configuration.
  module Logger
    class << self
      # Creates a new {::Logger} outputting to standard error with the given
      # severity level and a custom format.
      # @param level [Symbol, String] The name of the log level to use.
      # @return [::Logger] The {::Logger} object.
      def get_logger(level)
        logger = ::Logger.new(STDERR)
        logger.level = get_level_constant(level)
        logger.formatter = proc do |severity, datetime, _progname, msg|
          "[#{datetime.utc}] #{severity}: #{msg}\n"
        end
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
