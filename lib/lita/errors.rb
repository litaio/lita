module Lita
  # The root exception class that all Lita-specific exceptions inherit from.
  # @since 4.0.0
  class Error < StandardError; end

  # An exception raised when a configuration attribute is invalid.
  # @since 4.0.0
  class ValidationError < Error; end
end
