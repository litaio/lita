module Lita
  # A timer that executes a block after a certain number of seconds, either once or repeatedly.
  # @since 3.0.0
  class Timer
    # @param interval [Integer] The number of seconds to wait before calling the block.
    # @param recurring [Boolean] If true, the timer will fire repeatedly until stopped.
    # @yieldparam timer [Lita::Timer] The current {Lita::Timer} instance.
    def initialize(interval: 0, recurring: false, &block)
      @interval = interval
      @recurring = recurring
      @running = false
      @block = block
    end

    # Starts running the timer.
    def start
      @running = true
      run
    end

    # Stops the timer, preventing any further invocations of the block until started again.
    def stop
      @running = false
    end

    private

    # Is this a recurring timer?
    def recurring?
      @recurring
    end

    # Sleep for the given interval, call the block, then run again if it's a recurring timer.
    def run
      loop do
        sleep @interval
        @block.call(self) if running? && @block
        break unless running? && recurring?
      end
    end

    # Is the timer currently running?
    def running?
      @running
    end
  end
end
