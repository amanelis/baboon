# -*- encoding: utf-8 -*-
require File.expand_path('../lib/baboon/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ['Alex Manelis']
  s.email         = ['amanelis@gmail.com']
  s.description   = %q{A lite deployment package for rails applications.}
  s.summary       = %q{Add a configuration file, setup and deploy.}
  s.homepage      = ''

  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.name          = 'baboon'
  s.require_paths = ['lib']
  s.version       = Baboon::VERSION

  s.rubyforge_project = 'baboon'

  s.add_dependency 'rails'
  s.add_dependency 'rake'
  
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-core'
  s.add_development_dependency 'rspec-mocks'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-expectations'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'faker'
end
