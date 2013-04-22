require "spec_helper"

describe Lita::Command do
  before do
    module Lita
      class TestCommand < Command
      end
    end
  end

  after do
    Lita.commands.delete_at(0)
    Lita.send(:remove_const, :TestCommand)
  end

  it "registers descendants with the main registry" do
    expect(Lita.commands).to include(Lita::TestCommand)
  end
end
