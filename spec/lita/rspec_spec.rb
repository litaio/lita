require "spec_helper"

handler_class = Class.new(Lita::Handler) do
  route(/\w{3}/, to: :foo)
  route(/\w{4}/, to: :blah, command: true)

  def foo(matches)
  end

  def blah(matches)
  end

  def self.name
    "Lita::Handlers::Test"
  end
end

describe handler_class, lita: true do
  it { routes("foo").to(:foo) }
  it { routes("#{robot.name}: blah").to(:blah) }
  it { doesnt_route("blah").to(:blah) }
  it { does_not_route("blah").to(:blah) }
end
