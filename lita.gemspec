# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lita/version"

Gem::Specification.new do |spec|
  spec.name          = "lita"
  spec.version       = Lita::VERSION
  spec.authors       = ["Jimmy Cuadra"]
  spec.email         = ["jimmy@jimmycuadra.com"]
  spec.description   = %q{A multi-service chat bot with extendable behavior.}
  spec.summary       = %q{A multi-service chat bot with extendable behavior.}
  spec.homepage      = "https://github.com/jimmycuadra/lita"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "bundler", "~> 1.3"
  spec.add_runtime_dependency "redis-namespace", "~> 1.3.0"
  spec.add_runtime_dependency "thor", "~> 0.18.1"

  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 2.14.0rc1"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end
