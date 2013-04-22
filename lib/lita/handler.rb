module Lita
  class Handler
    def self.match(pattern = nil)
      if pattern.nil?
        defined?(@match) && @match
      else
        @match = pattern
      end
    end

    def self.match?(message)
      match === message.body
    end
  end
end
