# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lita/version"

Gem::Specification.new do |spec|
  spec.name          = "lita"
  spec.version       = Lita::VERSION
  spec.authors       = ["Jimmy Cuadra"]
  spec.email         = ["jimmy@jimmycuadra.com"]
  spec.description   = "ChatOps for Ruby."
  spec.summary       = "ChatOps framework for Ruby. Lita is a robot companion for your chat room."
  spec.homepage      = "https://github.com/litaio/lita"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.5.0"
  spec.required_rubygems_version = ">= 2.7.6"

  spec.metadata = {
    "bug_tracker_uri"   => "https://github.com/litaio/lita/issues",
    "changelog_uri"     => "https://github.com/litaio/lita/releases",
    "documentation_uri" => "https://docs.lita.io/",
    "homepage_uri"      => "https://www.lita.io/",
    "mailing_list_uri"  => "https://groups.google.com/group/litaio",
    "source_code_uri"   => "https://github.com/litaio/lita",
  }

  spec.add_runtime_dependency "bundler", "~> 1.16.1"
  spec.add_runtime_dependency "faraday", "~> 0.14.0"
  spec.add_runtime_dependency "http_router", "~> 0.11.2"
  spec.add_runtime_dependency "i18n", "~> 1.0.0"
  spec.add_runtime_dependency "ice_nine", "~> 0.11.2"
  spec.add_runtime_dependency "lita-default-handlers", "~> 0.1.0"
  spec.add_runtime_dependency "puma", "~> 3.11.2"
  spec.add_runtime_dependency "rack", "~> 2.0.4"
  spec.add_runtime_dependency "rb-readline", "~> 0.5.5"
  spec.add_runtime_dependency "redis-namespace", "~> 1.6.0"
  spec.add_runtime_dependency "thor", "~> 0.19.4"

  spec.add_development_dependency "coveralls", "~> 0.8.21"
  spec.add_development_dependency "rack-test", "~> 0.8.2"
  spec.add_development_dependency "rake", "~> 12.3.0"
  spec.add_development_dependency "rspec", "~> 3.7.0"
  spec.add_development_dependency "simplecov", "~> 0.14.1"

  if RUBY_PLATFORM == "java"
    spec.add_development_dependency "pry", "~> 0.11.3"
  else
    spec.add_development_dependency "pry-byebug", "~> 3.6.0"
  end

  spec.add_development_dependency "rubocop", "~> 0.52.1"
end
