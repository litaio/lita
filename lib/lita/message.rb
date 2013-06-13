module Lita
  class Message
    attr_reader :body, :source
    alias_method :message, :body

    def initialize(body, source)
      @body = body
      @source = source
    end
  end
end
