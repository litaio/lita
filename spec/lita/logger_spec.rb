require "spec_helper"

describe Lita::Logger do
  it "uses a custom log level" do
    logger = described_class.get_logger(:debug)
    expect(logger.level).to eq(Logger::DEBUG)
  end

  it "uses the info level if the config is nil" do
    logger = described_class.get_logger(nil)
    expect(logger.level).to eq(Logger::INFO)
  end

  it "uses the info level if the config level is invalid" do
    logger = described_class.get_logger(:foo)
    expect(logger.level).to eq(Logger::INFO)
  end

  it "logs messages with a custom format" do
    stderr = StringIO.new
    stub_const("STDERR", stderr)
    logger = described_class.get_logger(:debug)
    logger.fatal "foo"
    expect(stderr.string).to match(/^\[.+\] FATAL: foo$/)
  end
end
