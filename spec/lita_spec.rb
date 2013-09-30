require "spec_helper"

describe Lita do
  it "memoizes a Config" do
    expect(described_class.config).to be_a(Lita::Config)
    expect(described_class.config).to eql(described_class.config)
  end

  it "memoizes a template root" do
    expect(described_class.template_root).to match(/lita\/templates$/)
  end

  describe ".url_for" do
    it "returns a relative url when public_url is blank" do
      expect(described_class.url_for).to eq("/")
      expect(described_class.url_for("/")).to eq("/")
      expect(described_class.url_for("/lita/help")).to eq("/lita/help")
      expect(described_class.url_for("/h/p")).to eq("/h/p")
    end

    it "returns an absolute url when public_url is set" do
      described_class.configure { |c| c.public_url = "http://lita.io/" }
      expect(described_class.url_for).to eq("http://lita.io/")
      expect(described_class.url_for("/")).to eq("http://lita.io/")
      expect(described_class.url_for("/help")).to eq("http://lita.io/help")
      expect(described_class.url_for("/h/p")).to eq("http://lita.io/h/p")
    end
  end

  describe ".configure" do
    it "yields the Config object" do
      described_class.configure { |c| c.robot.name = "Not Lita" }
      expect(described_class.config.robot.name).to eq("Not Lita")
    end
  end

  describe ".redis" do
    it "memoizes a Redis::Namespace" do
      expect(described_class.redis).to respond_to(:namespace)
      expect(described_class.redis).to eql(described_class.redis)
    end
  end

  describe ".run" do
    before { Lita.config }

    it "runs a new Robot" do
      expect_any_instance_of(Lita::Robot).to receive(:run)
      described_class.run
    end
  end
end
