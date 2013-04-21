# Lita

**Lita** is a chat bot. It is agnostic to chat service, using separate adapters to hook into a given chat service while providing the same high level API. New behavior can be added to the bot with listener plugins.

## Installation

To run an instance of Lita, you just need to install the gem, an adapter gem for your chat service of choice, and any listener gems you'd like. (More details on adapters and listeners can be found below.) It is recommended that you use Bundler and create a Gemfile like this:

``` ruby
source "https://rubygems.org"

gem "lita"
gem "lita-hipchat"
gem "lita-karma"
```

To start Lita, simply run `bundle exec lita`.

## Configuration

When Lita starts, it will look for a file named `lita_config.rb` in the root of the project. If it exists, it will be run and any configuration within the file will override the defaults. A Lita config file looks like this:

``` ruby
Lita.configure do |config|
  config.robot.name = "Phil"
  config.robot.adapter = :hipchat
  config.adapter.some_key = :some_value
  config.listeners.karma.my_key = :my_value
end
```

The config object has three main attributes, upon which more configuration attributes are set:

1. `robot` - Configuration for the main Lita robot itself.
1. `adapter` - Configuration for the selected chat service adapter.
1. `listeners` - Configuration for individual listeners. Each listener has its own config attribute.

If you're deploying Lita to Heroku and don't want to hard code secret configuration, such as passwords, into `lita_config.rb`, you can set the value in the config file to pull from environment variables, and then set your secret information to environment variables via Heroku's command line interface.

In `lita_config.rb`:

``` ruby
config.adapter.password = ENV["LITA_HIPCHAT_PASSWORD"]
```

At the command line:

``` bash
heroku config:set LITA_HIPCHAT_PASSWORD=secret
```

## Adapters

Lita can be used with any chat service, given that there is an adapter for that service. Lita defaults to using the built-in shell adapter, so you can test it out right in your terminal. Additional adapters can be installed as gems. Use Lita's configuration file to set which adapter you want to use when running the `lita` command.

An adapter is any class that inherits from `Lita::Adapter::Base` and whose instances implement the required API. Here is a simple example:

``` ruby
module Lita
  module Adapter
    module NoOp < Base
      # Implement required methods here.
    end
  end
end
```

See the API documentation for the methods adapters are required to implement. Adapters are published as Ruby gems.

To use the adapter from the example, assuming it was published as a gem named "lita-no-op", you'd add the gem to your Gemfile, and then set the following configuration option in `lita_config.rb`:

``` ruby
config.robot.adapter = :no_op
```

## Listeners

Lita uses listener objects to respond to messages she overhears or that are directed to her. A listener is any class that inherits from `Lita::Listener::Base` and whose instances respond to `call`. When Lita receives a message, she passes it to all defined listeners, and they are free to respond as they please based on the message's content. Here is a simple example of a listener that simply echoes back any text in a message beginning with "echo":

``` ruby
module Lita
  module Listener
    class Echo < Base
      def call
        input = message =~ /^echo\s+(.+)/ && $1
        say(input) if input
      end
    end
  end
end
```

See the API documentation for all the methods available to listeners. Listeners are published as Ruby gems. To add a listener to your instance of Lita, just add the gem to your Gemfile.

## Acknowledgements

[Hubot](https://github.com/github/hubot) and its contributors for a great deal of inspiration.

## License

[MIT](http://opensource.org/licenses/MIT)
