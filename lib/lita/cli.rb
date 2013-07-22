require "thor"

module Lita
  # The command line interface for Lita.
  class CLI < Thor
    include Thor::Actions

    def self.source_root
      File.expand_path("../../..", __FILE__)
    end

    default_task :start

    class_option :config,
      aliases: "-c",
      banner: "PATH",
      default: "lita_config.rb",
      desc: "Path to the configuration file to use"
    
    class_option :daemon,
      aliases: "-d",
      banner: "DAEMON",
      default: false,
      desc: "Flag to enable daemonization"
      
    class_option :pid_file,
      aliases: "-p",
      banner: "PID_FILE",
      default: "/var/run/lita.pid",
      desc: "Location for pid files when daemonized"
    
    class_option :stdout,
      aliases: "-o",
      banner: "STDOUT",
      default: "/var/log/lita.stdout.log",
      desc: "Where to direct stdout"
      
    class_option :stderr,
      aliases: "-e",
      banner: "STDERR",
      default: "/var/log/lita.stderr.log",
      desc: "Where to direct stderr"
      
    desc "start", "Starts Lita"
    def start
      Bundler.require
      setup_daemon if options[:daemon]
      Lita.run(options[:config])
    end

    desc "new NAME", "Generates a new Lita project (default name: lita)"
    def new(name = "lita")
      directory "skeleton", name
    end
    
    private
    
    def setup_daemon
      # Rename the process so it's obvious in process lists
      $0 = "lita"

      # Spawn a deamon for our bot
      Lita::Daemon.daemonize(:pid_file => options[:pid_file], :stdout_file => options[:stdout], :stderr_file => options[:stderr])

      # Set up signals for our daemon so it knows how to exit
      Signal.trap("QUIT") { exit }
      %w(HUP INT).each do |signal|
        Signal.trap(signal, "IGNORE")
      end
    end
    
  end
end
