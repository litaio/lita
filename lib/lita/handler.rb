module Lita
  # Base class for objects that add new behavior to Lita.
  class Handler
    extend Forwardable
    extend ChatRouter
    extend HTTPRouter
    extend EventRouter
  end
end
