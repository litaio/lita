require "thor"

require_relative "common"
require_relative "daemon"
require_relative "version"

module Lita
  # The command line interface for Lita.
  class CLI < Thor
    include Thor::Actions

    def self.source_root
      Lita.template_root
    end

    def self.file_path_for(file_name, default_path)
      base_path = Process.euid == 0 ? default_path : ENV["HOME"]
      File.join(base_path, file_name)
    end

    default_task :start

    desc "start", "Starts Lita"
    option :config,
      aliases: "-c",
      banner: "PATH",
      default: File.expand_path("lita_config.rb", Dir.pwd),
      desc: "Path to the configuration file to use"
    option :daemonize,
      aliases: "-d",
      default: false,
      desc: "Run Lita as a daemon",
      type: :boolean
    option :log_file,
      aliases: "-l",
      banner: "PATH",
      default: file_path_for("lita.log", "/var/log"),
      desc: "Path where the log file should be written when daemonized"
    option :pid_file,
      aliases: "-p",
      banner: "PATH",
      default: file_path_for("lita.pid", "/var/run"),
      desc: "Path where the PID file should be written when daemonized"
    option :kill,
      aliases: "-k",
      default: false,
      desc: "Kill existing Lita processes when starting the daemon",
      type: :boolean
    def start
      begin
        Bundler.require
      rescue Bundler::GemfileNotFound
        say I18n.t("lita.cli.no_gemfile_warning"), :red
        abort
      end

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
      directory "robot", name
    end

    desc "adapter NAME", "Generates a new Lita adapter"
    def adapter(name)
      generate_templates(generate_config(name, "adapter"))
    end

    desc "handler NAME", "Generates a new Lita handler"
    def handler(name)
      generate_templates(generate_config(name, "handler"))
    end

    desc "version", "Outputs the current version of Lita"
    def version
      puts VERSION
    end
    map %w(-v --version) => :version

    private

    def generate_config(name, plugin_type)
      name, gem_name = normalize_names(name)
      constant_name = name.split(/_/).map { |p| p.capitalize }.join
      namespace = "#{plugin_type}s"
      constant_namespace = namespace.capitalize
      spec_type = plugin_type == "handler" ? "lita_handler" : "lita"
      required_lita_version = Lita::VERSION.split(/\./)[0...-1].join(".")

      {
        name: name,
        gem_name: gem_name,
        constant_name: constant_name,
        plugin_type: plugin_type,
        namespace: namespace,
        constant_namespace: constant_namespace,
        spec_type: spec_type,
        required_lita_version: required_lita_version
      }.merge(generate_user_config).merge(optional_content)
    end

    def generate_user_config
      git_user = `git config user.name`.chomp
      git_user = "TODO: Write your name" if git_user.empty?
      git_email = `git config user.email`.chomp
      git_email = "TODO: Write your email address" if git_email.empty?

      {
        author: git_user,
        email: git_email
      }
    end

    def generate_templates(config)
      name = config[:name]
      gem_name = config[:gem_name]
      namespace = config[:namespace]
      travis = config[:travis]

      target = File.join(Dir.pwd, gem_name)

      template(
        "plugin/lib/lita/plugin_type/plugin.tt",
        "#{target}/lib/lita/#{namespace}/#{name}.rb",
        config
      )
      template("plugin/lib/plugin.tt", "#{target}/lib/#{gem_name}.rb", config)
      template(
        "plugin/spec/lita/plugin_type/plugin_spec.tt",
        "#{target}/spec/lita/#{namespace}/#{name}_spec.rb",
        config
      )
      template(
        "plugin/spec/spec_helper.tt",
        "#{target}/spec/spec_helper.rb",
        config
      )
      copy_file("plugin/Gemfile", "#{target}/Gemfile")
      template("plugin/gemspec.tt", "#{target}/#{gem_name}.gemspec", config)
      copy_file("plugin/gitignore", "#{target}/.gitignore")
      copy_file("plugin/travis.yml", "#{target}/.travis.yml") if travis
      template("plugin/LICENSE.tt", "#{target}/LICENSE", config)
      copy_file("plugin/Rakefile", "#{target}/Rakefile")
      template("plugin/README.tt", "#{target}/README.md", config)
    end

    def normalize_names(name)
      name = name.downcase.sub(/^lita[_-]/, "")
      gem_name = "lita-#{name}"
      name = name.tr("-", "_")
      [name, gem_name]
    end

    def optional_content
      {
        travis: yes?(I18n.t("lita.cli.travis_question")),
        coveralls: yes?(I18n.t("lita.cli.coveralls_question"))
      }
    end
  end
end
