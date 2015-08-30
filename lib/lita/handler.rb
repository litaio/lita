require_relative "handler/chat_router"
require_relative "handler/http_router"
require_relative "handler/event_router"

module Lita
  # Base class for objects that add new behavior to Lita. {Handler} is simply a class with all
  # types of routers mixed in.
  class Handler
    extend ChatRouter
    extend HTTPRouter
    extend EventRouter
  end
end
