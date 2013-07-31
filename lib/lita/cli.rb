require "thor"

require "lita/daemon"

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
      default: File.expand_path("lita_config.rb", Dir.pwd),
      desc: "Path to the configuration file to use"

    class_option :daemonize,
      aliases: "-d",
      default: false,
      desc: "Run Lita as a daemon",
      type: :boolean

    class_option :log_file,
      aliases: "-l",
      banner: "PATH",
      default: Process.euid == 0 ?
        "/var/log/lita.log" : File.expand_path("lita.log", ENV["HOME"]),
      desc: "Path where the log file should be written when daemonized"

    class_option :pid_file,
      aliases: "-p",
      banner: "PATH",
      default: Process.euid == 0 ?
        "/var/run/lita.pid" : File.expand_path("lita.pid", ENV["HOME"]),
      desc: "Path where the PID file should be written when daemonized"

    class_option :kill,
      aliases: "-k",
      default: false,
      desc: "Kill existing Lita processes when starting the daemon",
      type: :boolean

    desc "start", "Starts Lita"
    def start
      Bundler.require

      if options[:daemonize]
        Daemon.new(
          options[:pid_file],
          options[:log_file],
          options[:kill]
        ).daemonize
      end

      Lita.run(options[:config])
    end

    desc "new NAME", "Generates a new Lita project (default name: lita)"
    def new(name = "lita")
      directory "skeleton", name
    end
  end
end
