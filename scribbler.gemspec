# -*- encoding: utf-8 -*-
require File.expand_path('../lib/scribbler/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jon Phenow"]
  gem.email         = ["jon.phenow@tstmedia.com"]
  gem.description   = %q{}
  gem.summary       = %q{}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "scribbler"
  gem.require_paths = ["lib"]
  gem.version       = Scribbler::VERSION

  gem.add_dependency 'activesupport'
  gem.add_dependency 'rake'

  gem.add_development_dependency 'rspec'
end
