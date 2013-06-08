describe Lita::Adapters::Shell do
  let(:robot) { double("Robot") }

  subject { described_class.new(robot) }

  describe "#say" do
    it "prints its input" do
      expect(subject).to receive(:puts).with("foo")
      subject.say("foo")
    end
  end
end
