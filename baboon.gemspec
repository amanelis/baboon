# -*- encoding: utf-8 -*-
require File.expand_path('../lib/baboon/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alex Manelis"]
  gem.email         = ["amanelis@gmail.com"]
  gem.description   = %q{A lite weight deployment package for rails applications}
  gem.summary       = %q{Add a configuration file, setup and deploy}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "baboon"
  gem.require_paths = ["lib"]
  gem.version       = Baboon::VERSION

  gem.add_development_dependency "rspec"
  gem.rubyforge_project = "baboon"
end
