module Lita
  # Base class for objects that add new behavior to Lita. {Handler} is simply a class with all
  # types of routers mixed in.
  class Handler
    extend ChatRouter
    extend HTTPRouter
    extend EventRouter
  end
end
