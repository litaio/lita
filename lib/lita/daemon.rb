module Lita
  class Daemon
    
    ForkingException = Class.new(Exception)
    
    # Get us ready for daemonization
    def self.daemonize(options = { })
      # Kill the original parent process if we can fork
      case fork
      when nil
        # Break away from the terminal, become a new process & group leader
        Process.setsid
        start(fork, options)
      when -1
        raise ForkingException, "Forking failed for some reason.  Does this OS support forking?"
      else
        exit
      end
    end
    
    private
    
    # Starts the final form of the daemon, writes out a pid, redirects logs, etc.
    def self.start(pid, options = { })
      pid_file    = options[:pid_file] || "/tmp/lita.pid"
      stdout_file = options[:stdout_file] || "/tmp/lita.stdout.log"
      stderr_file = options[:stderr_file] || "/tmp/lita.stderr.log"
      
      case pid
      when nil
        # nil for the fork value means we're in the child process
        redirect_streams(stdout_file, stderr_file)
      when -1
        # Couldn't fork for some reason - usually OS related
        raise ForkingException, "Forking failed for some reason.  Does this OS support forking?"
      else
        # Try to kill any existing processes, write pid, exit
        write_pid(pid, pid_file) if kill(pid, pid_file)
        exit
      end
    end
    
    # Attempts to write the pid of the forked process to the pid file
    def self.write_pid(pid, pid_file)
      File.open(pid_file, "w") { |f| f.write(pid) }
    rescue Errno::EPERM, Errno::EACCES
      safe_pid_location = File.join(Dir.home, "lita.pid")
      warn "Unable to write pid to: #{pid_file}.  Writing pid to #{safe_pid_location} instead."
      File.open(safe_pid_location, "w") { |f| f.write(pid) }
    rescue ::Exception => e
      $stderr.puts "Unable to write pid file: unexpected #{e.class}: #{e}"
      Process.kill("QUIT", pid)
    end

    # Attempts to kill any existing processes for rolling restarts
    def self.kill(pid, pidfile)
      existing_pid = open(pidfile).read.strip.to_i
      Process.kill("QUIT", existing_pid)
      true
    rescue Errno::ESRCH, Errno::ENOENT
      true
    rescue Errno::EPERM
      $stderr.puts "Permission denied trying to kill #{existing_pid}: Errno::EPERM"
      false
    rescue ::Exception => e
      $stderr.puts "Unexpected #{e.class}: #{e}"
      false
    end

    # Redirect the stdout and stderr to log files
    def self.redirect_streams(outfile, errfile)
      redirect_stream($stdin, '/dev/null', 'stdin', mode: 'r', sync: false)
      redirect_stream($stdout, outfile, 'stdout')
      redirect_stream($stderr, errfile, 'stderr')
    end
    
    def self.redirect_stream(stream, location, stream_name, mode: 'a', sync: true)
      log_file = File.new(location, mode)
    rescue Errno::EPERM, Errno::EACCESS
      default_location = File.join(Dir.home, "lita.#{stream_name}.log")
      warn "Unable to write to: #{location}. Writing to `#{default_location}' instead."
      log_file = File.new(default_location, mode)
    ensure
      stream.reopen(log_file)
      stream.sync = sync
    end
    
  end
end
