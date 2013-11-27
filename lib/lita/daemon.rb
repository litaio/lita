require "fileutils"

module Lita
  # Converts Lita to a daemon process.
  class Daemon
    # @param pid_path [String] The path to the PID file.
    # @param log_path [String] The path to the log file.
    # @param kill_existing [Boolean] Whether or not to kill existing processes.
    def initialize(pid_path, log_path, kill_existing)
      @pid_path = pid_path
      @log_path = log_path
      @kill_existing = kill_existing
    end

    # Converts Lita to a daemon process.
    # @return [void]
    def daemonize
      handle_existing_process
      Process.daemon(true)
      File.open(@pid_path, "w") { |f| f.write(Process.pid) }
      set_up_logs
      at_exit { FileUtils.rm(@pid_path) if File.exist?(@pid_path) }
    end

    private

    # Abort if Lita is already running.
    def ensure_not_running
      if File.exist?(@pid_path)
        abort <<-FATAL.chomp
PID file exists at #{@pid_path}. Lita may already be running. \
Kill the existing process or remove the PID file and then start Lita.
FATAL
      end
    end

    # Call the appropriate method depending on kill mode.
    def handle_existing_process
      if @kill_existing && File.exists?(@pid_path)
        kill_existing_process
      else
        ensure_not_running
      end
    end

    # Try to kill an existing process.
    def kill_existing_process
      pid = File.read(@pid_path).strip.to_i
      Process.kill("TERM", pid)
    rescue Errno::ESRCH, RangeError, Errno::EPERM
      abort "Failed to kill existing Lita process #{pid}."
    end

    # Redirect the standard streams to a log file.
    def set_up_logs
      log_file = File.new(@log_path, "a")
      $stdout.reopen(log_file)
      $stderr.reopen(log_file)
      $stderr.sync = $stdout.sync = true
    end
  end
end
