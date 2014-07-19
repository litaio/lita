require "spec_helper"

builder = Lita::Builder.new(:test) do
  route(/namespace/) { |response| response.reply(self.class.namespace) }
end

handler = builder.build_handler

describe handler, lita_handler: true do
  it "builds a handler from a block" do
    send_message("namespace")
    expect(replies.last).to eq("test")
  end
end
