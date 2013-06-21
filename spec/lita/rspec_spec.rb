require "spec_helper"

handler_class = Class.new(Lita::Handler) do
  route(/\w{3}/, to: :foo)
  route(/\w{4}/, to: :blah, command: true)

  def foo(matches)
    reply "baz"
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

  describe "#foo" do
    it "replies with baz" do
      expect_reply("baz")
      send_test_message("foo")
    end

    it "doesn't reply with blam" do
      expect_no_reply("blam")
      send_test_message("foo")
    end
  end
end
