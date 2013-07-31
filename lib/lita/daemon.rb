require "fileutils"

module Lita
  class Daemon
    def initialize(pid_path, log_path, kill_existing)
      @pid_path = pid_path
      @log_path = log_path
      @kill_existing = kill_existing
    end

    def daemonize
      handle_existing_process
      Process.daemon(true)
      File.open(@pid_path, "w") { |f| f.write(Process.pid) }
      set_up_logs
      at_exit { FileUtils.rm(@pid_path) if File.exist?(@pid_path) }
    end

    private

    def ensure_not_running
      if File.exist?(@pid_path)
        abort <<-FATAL.chomp
PID file exists at #{@pid_path}. Lita may already be running. \
Kill the existing process or remove the PID file and then start Lita.
FATAL
      end
    end

    def handle_existing_process
      if @kill_existing
        kill_existing_process
      else
        ensure_not_running
      end
    end

    def kill_existing_process
      pid = File.read(@pid_path).strip.to_i
      Process.kill("TERM", pid)
    rescue Errno::ESRCH, RangeError, Errno::EPERM
      abort "Failed to kill existing Lita process #{pid}."
    end

    def set_up_logs
      log_file = File.new(@log_path, "a")
      $stdout.reopen(log_file)
      $stderr.reopen(log_file)
      $stderr.sync = $stdout.sync = true
    end
  end
end
