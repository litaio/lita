module Lita
  class Error < StandardError; end

  class UnknownAdapterError < Error; end
  class ConfigError < Error; end
end
