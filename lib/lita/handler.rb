module Lita
  # Base class for objects that add new behavior to Lita.
  class Handler
    extend ChatRouter
    extend HTTPRouter
    extend EventRouter
  end
end
