# frozen_string_literal: true

Lita.configure do |config|
  # The name your robot will use.
  config.robot.name = "Lita"

  ## An array identifiers for users who are considered administrators. These
  ## users have the ability to add and remove other users from authorization
  ## groups. What is considered a user ID will change depending on which adapter
  ## you use.
  # config.robot.admins = ["1", "2"]

  # The adapter you want to connect with. Make sure you've added the
  # appropriate gem to the Gemfile.
  config.robot.adapter = :shell

  ## Example: Set options for the chosen adapter.
  # config.adapter.username = "myname"
  # config.adapter.password = "secret"

  ## Example: Set options for the Redis connection.
  # config.redis[:host] = "127.0.0.1"
  # config.redis[:port] = 1234

  ## Example: Set configuration for any loaded handlers. See the handler's
  ## documentation for options.
  # config.handlers.example_handler.example_attribute = "example value"
end
