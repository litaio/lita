module Lita
  # The root exception class that all Lita-specific exceptions inherit from.
  # @since 4.0.0
  class Error < StandardError; end

  # An exception raised when a custom validation is set on a configuration attribute that is
  # violated by the default value of the attribute.
  # @since 4.0.0
  class ValidationError < Error; end

  # An exception raised when Lita can't connect to Redis in test mode.
  # @since 4.0.3
  class RedisError < Error; end

  # An exception raised when attempting to resolve a template that doesn't exist.
  # @since 4.2.0
  class MissingTemplateError < Error; end

  # An exception raised when a handler attempts to render a template without having set its
  # template root.
  # @since 4.2.0
  class MissingTemplateRootError < Error; end
end
