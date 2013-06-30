require "spec_helper"

handler_class = Class.new(Lita::Handler) do
  route(/^\w{3}$/, to: :foo)
  route(/^\w{4}$/, to: :blah, command: true)

  def foo(matches)
    reply "baz"
  end

  def blah(matches)
    reply "bongo", "wongo"
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
      send_message("foo")
      expect(replies).to eq(["baz"])
    end
  end

  describe "#blah" do
    it "replies with bongo and wongo" do
      send_command("blah")
      expect(replies).to eq(["bongo", "wongo"])
    end
  end
end
