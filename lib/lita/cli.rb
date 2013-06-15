require "thor"

module Lita
  class CLI < Thor
    include Thor::Actions

    def self.source_root
      File.expand_path("../../..", __FILE__)
    end

    default_task :start

    desc "start", "Starts Lita"
    def start
      Bundler.require
      Lita.run
    end

    desc "new NAME", "Generates a new Lita project (default name: lita)"
    def new(name = "lita")
      directory "skeleton", name
    end
  end
end
