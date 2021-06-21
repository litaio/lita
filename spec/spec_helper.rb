# frozen_string_literal: true

# Generate code coverage metrics outside CI.
unless ENV["CI"]
  require "simplecov"
  SimpleCov.start { add_filter "/spec/" }
end

require "pry"
require "lita/rspec"

RSpec.configure do |config|
  config.mock_with :rspec do |mocks_config|
    mocks_config.verify_doubled_constant_names = true
    mocks_config.verify_partial_doubles = true
  end

  # Lita calls `exit(false)` in a few places. If an RSpec example hits one of these calls and it
  # wasn't explicitly stubbed, the example will stop at exactly that point, but will be reported by
  # RSpec as having passed, and will also change RSpec's exit code to 1. This situation indicates
  # either a missing stub or a real bug, so we catch it here and fail loudly.
  #
  # https://github.com/rspec/rspec-core/issues/2246
  config.around do |example|
    example.run
  rescue SystemExit => e
    raise <<~ERROR
      Unhandled SystemExit! This will cause RSpec to exit 1 but show the example as passing!"

      Full backtrace:

      #{e.backtrace.join("\n")}
    ERROR
  end
end
