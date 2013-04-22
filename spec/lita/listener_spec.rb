require "spec_helper"

describe Lita::Listener do
  before do
    module Lita
      class TestListener < Listener
      end
    end
  end

  after do
    Lita.listeners.delete_at(0)
    Lita.send(:remove_const, :TestListener)
  end

  it "registers descendants with the main registry" do
    expect(Lita.listeners).to include(Lita::TestListener)
  end
end
