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

    desc "start", "Starts Lita"
    def start
      Bundler.require
      Lita.run(options[:config])
    end

    desc "new NAME", "Generates a new Lita project (default name: lita)"
    def new(name = "lita")
      directory "skeleton", name
    end
  end
end
