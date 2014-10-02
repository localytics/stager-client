# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stager/version'

Gem::Specification.new do |spec|
  spec.name          = "stager"
  spec.version       = Stager::VERSION
  spec.authors       = ["Brian Zeligson"]
  spec.email         = ["bzeligson@localytics.com"]
  spec.summary       = %q{Client utility for working with Stager}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_dependency "thor"
  spec.add_dependency "github_api"
  spec.add_dependency "httparty"
  spec.add_dependency "configliere"
  spec.add_dependency "launchy"
end
