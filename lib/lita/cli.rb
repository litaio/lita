require "thor"

require_relative "common"
require_relative "daemon"
require_relative "version"

module Lita
  # The command line interface for Lita.
  class CLI < Thor
    include Thor::Actions

    # The root file path for the templates directory.
    # @note This is a magic method required by Thor for file operations.
    # @return [String] The path.
    def self.source_root
      Lita.template_root
    end

    # Returns the full destination file path for the given file, using the supplied +default_path+
    # as the base if run as root, otherwise falling back to the user's home directory.
    # @param file_name [String] The name of the file.
    # @param default_path [String] The base of the file path to use when run as root.
    # @return [String] The full file path.
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
    # Starts Lita.
    # @return [void]
    def start
      begin
        Bundler.require
      rescue Bundler::GemfileNotFound
        say I18n.t("lita.cli.no_gemfile_warning"), :red
        abort
      end

      if options[:daemonize]
        say I18n.t("lita.cli.daemon_deprecated"), :red

        Daemon.new(
          options[:pid_file],
          options[:log_file],
          options[:kill]
        ).daemonize
      end

      Lita.run(options[:config])
    end

    desc "new NAME", "Generates a new Lita project (default name: lita)"
    # Generates a new Lita project.
    # @param name [String] The directory name for the new project.
    # @return [void]
    def new(name = "lita")
      directory "robot", name
    end

    desc "adapter NAME", "Generates a new Lita adapter"
    # Generates a new Lita adapter.
    # @param name [String] The name for the new adapter.
    # @return [void]
    def adapter(name)
      config = generate_config(name, "adapter")
      generate_templates(config)
      post_messages(config)
    end

    desc "handler NAME", "Generates a new Lita handler"
    # Generates a new Lita handler.
    # @param name [String] The name for the new handler.
    # @return [void]
    def handler(name)
      config = generate_config(name, "handler")
      generate_templates(config)
      post_messages(config)
    end

    desc "extension NAME", "Generates a new Lita extension"
    # Generates a new Lita extension.
    # @param name [String] The name for the new extension.
    # @return [void]
    def extension(name)
      config = generate_config(name, "extension")
      generate_templates(config)
      post_messages(config)
    end

    desc "version", "Outputs the current version of Lita"
    # Outputs the current version of Lita.
    # @return [void]
    def version
      puts VERSION
    end
    map %w(-v --version) => :version

    private

    def badges_message
      say I18n.t("lita.cli.badges_reminder"), :yellow
    end

    def generate_config(name, plugin_type)
      name, gem_name = normalize_names(name)
      constant_name = name.split(/_/).map(&:capitalize).join
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
      template("plugin/spec/spec_helper.tt", "#{target}/spec/spec_helper.rb", config)
      template("plugin/locales/en.yml.tt", "#{target}/locales/en.yml", config)
      if config[:plugin_type] == "handler"
        copy_file("plugin/templates/gitkeep", "#{target}/templates/.gitkeep")
      end
      copy_file("plugin/Gemfile", "#{target}/Gemfile")
      template("plugin/gemspec.tt", "#{target}/#{gem_name}.gemspec", config)
      copy_file("plugin/gitignore", "#{target}/.gitignore")
      copy_file("plugin/travis.yml", "#{target}/.travis.yml") if travis
      copy_file("plugin/Rakefile", "#{target}/Rakefile")
      template("plugin/README.tt", "#{target}/README.md", config)
    end

    def license_message
      say I18n.t("lita.cli.license_notice"), :yellow
    end

    def normalize_names(name)
      name = name.downcase.sub(/^lita[_-]/, "")
      gem_name = "lita-#{name}"
      name = name.tr("-", "_")
      [name, gem_name]
    end

    def optional_content
      travis = yes?(I18n.t("lita.cli.travis_question"))
      coveralls = yes?(I18n.t("lita.cli.coveralls_question"))
      if travis || coveralls
        say I18n.t("lita.cli.badges_message")
        badges = yes?(I18n.t("lita.cli.badges_question"))
        github_user = ask(I18n.t("lita.cli.github_user_question")) if badges
      end
      {
        travis: travis,
        coveralls: coveralls,
        badges: badges,
        github_user: github_user
      }
    end

    def post_messages(config)
      license_message
      badges_message if config[:badges]
    end
  end
end
