module Lita
  # The root exception class that all Lita-specific exceptions inherit from.
  class Error < StandardError; end

  # An exception raised when a configuration attribute is invalid.
  class ValidationError < Error; end
end
