module Lita
  class Error < StandardError; end
  class ConfigError < Error; end
  class UnknownAdapterError < Error; end
end
