# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
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

  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata = {
    "bug_tracker_uri"   => "https://github.com/litaio/lita/issues",
    "changelog_uri"     => "https://github.com/litaio/lita/releases",
    "documentation_uri" => "https://docs.lita.io/",
    "homepage_uri"      => "https://www.lita.io/",
    "mailing_list_uri"  => "https://groups.google.com/group/litaio",
    "source_code_uri"   => "https://github.com/litaio/lita",
  }

  spec.add_runtime_dependency "bundler", "~> 2.2.3"
  spec.add_runtime_dependency "faraday", "~> 1.6.0"
  spec.add_runtime_dependency "http_router", "~> 0.11.2"
  spec.add_runtime_dependency "i18n", "~> 1.8.10"
  spec.add_runtime_dependency "ice_nine", "~> 0.11.2"
  spec.add_runtime_dependency "puma", "~> 5.4.0"
  spec.add_runtime_dependency "rack", "~> 2.2.3"
  spec.add_runtime_dependency "rb-readline", "~> 0.5.5"
  spec.add_runtime_dependency "redis-namespace", "~> 1.8.1"
  spec.add_runtime_dependency "thor", "~> 1.1.0"

  spec.add_development_dependency "pry-byebug", "~> 3.9.0"
  spec.add_development_dependency "rack-test", "~> 1.1.0"
  spec.add_development_dependency "rake", "~> 13.0.3"
  spec.add_development_dependency "rspec", "~> 3.10.0"
  spec.add_development_dependency "rubocop", "~> 1.17.0"
  spec.add_development_dependency "simplecov", "~> 0.21.2"
end
