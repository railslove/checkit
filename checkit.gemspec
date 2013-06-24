# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'checkit/version'

Gem::Specification.new do |gem|
  gem.name          = "checkit"
  gem.version       = Checkit::VERSION
  gem.authors       = ["Maximilian Schulz"]
  gem.email         = ["m.schulz@kulturfluss.de"]
  gem.description   = %q{A little helper to check the your ruby project dependencies}
  gem.summary       = %q{This gem provides an executable which checks common project dependencies. It checks if the bundle is installed, all servers are running and if your config files are in place.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'bundler'
  gem.add_dependency 'ansi'
end
