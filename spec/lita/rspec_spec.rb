require "spec_helper"

handler_class = Class.new(Lita::Handler) do
  listener :foo, "foo"
  command :bar, "bar"
  def foo; end
  def bar; end
end

describe handler_class, lita_handler: true do
  around do |example|
    Lita.register_handler(handler_class)
    example.run
    Lita.reset_registry
  end

  it "dispatches to foo" do
    handler_class.any_instance.should_receive(:foo)
    chat("bar foo baz")
  end

  it "dispatches to bar" do
    handler_class.any_instance.should_receive(:bar)
    chat("Lita bar baz")
  end

  it { handles("bar foo baz").with(:foo) }
  it { handles("Lita bar baz").with(:bar) }
  it { doesnt_handle("bar baz").with(:bar) }
end
