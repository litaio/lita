module Lita
  class Message
    attr_reader :body, :user

    def initialize(body, user)
      @body = body
      @user = user
    end

    def to_s
      body
    end
  end
end
