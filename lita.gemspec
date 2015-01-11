# coding: utf-8
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
  spec.homepage      = "https://github.com/jimmycuadra/lita"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_runtime_dependency "bundler", ">= 1.3"
  spec.add_runtime_dependency "faraday", ">= 0.8.7"
  spec.add_runtime_dependency "http_router", ">= 0.11.1"
  spec.add_runtime_dependency "ice_nine", ">= 0.11.0"
  spec.add_runtime_dependency "i18n", ">= 0.6.9"
  spec.add_runtime_dependency "multi_json", ">= 1.7.7"
  spec.add_runtime_dependency "puma", ">= 2.7.1"
  spec.add_runtime_dependency "rack", ">= 1.5.2"
  spec.add_runtime_dependency "rb-readline", ">= 0.5.1"
  spec.add_runtime_dependency "redis-namespace", ">= 1.3.0"
  spec.add_runtime_dependency "thor", ">= 0.18.1"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rubocop", "~> 0.28.0"
end
