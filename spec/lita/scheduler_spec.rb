require "spec_helper"

describe Lita::Scheduler, lita: true do
  let(:user) { double("Lita::User", name: "Test User") }

  let(:scheduler) do
    scheduler = double('Rufus::Scheduler::PlainScheduler')
    [:schedule, :cron, :at, :every].each do |method|
      allow(scheduler).to receive(method)
    end
    scheduler
  end

  let(:robot) { double("Lita::Robot", name: "Lita", scheduler: scheduler, send_messages: nil) }

  let(:scheduler_class) do
    Class.new(described_class) do
      schedule '0 * * * *',                 :schedule_job
      cron     '* 1 * * *',                 :cron_job1
      cron     '* * * * * Asia/Tokyo',      :cron_job2
      every    '1m',                        :every_job1
      every    '1s',                        :every_job2
      at       '2013-09-28 19:13:29 +0900', :at_job

      def schedule_job; end
      def cron_job1;    end
      def cron_job2;    end
      def every_job1;   end
      def every_job2;   end
      def at_job;       end

      def self.name
        "Lita::Schedulers::Test"
      end
    end
  end

  let(:incomplete_scheduler_class) do
    Class.new(scheduler_class) do
      every('1d', :not_defined_job)
    end
  end

  subject { described_class.new(robot) }

  describe '#send_message' do
    it 'raises an exception if message is nil' do
      expect { subject.send_message(user: 'foo', message: nil) }.to raise_error
    end

    it 'raises an exception if neither user nor room ' do
      expect { subject.send_message(message: 'foo') }.to raise_error
    end

    it 'does not raise an exception' do
      expect { subject.send_message(room: 'foo', message: 'bar') }.not_to raise_error
    end
  end

  describe '.start' do
    it 'does not raise an exception if all jobs are defined' do
      expect { scheduler_class.start(robot) }.not_to raise_error
    end

    it 'raises an exception if the job is not defined' do
      expect { incomplete_scheduler_class.start(robot) }.to raise_error
    end
  end

  describe ".namespace" do
    it "provides a snake cased namespace for the scheduler" do
      scheduler_class = Class.new(described_class) do
        def self.name
          "Lita::Schedulers::FooBarBaz"
        end
      end
      expect(scheduler_class.namespace).to eq("foo_bar_baz")
    end

    it "raises an exception if the scheduler doesn't define self.name" do
      scheduler_class = Class.new(described_class)
      expect { scheduler_class.namespace }.to raise_error
    end
  end
end