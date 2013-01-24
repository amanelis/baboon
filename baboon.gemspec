# -*- encoding: utf-8 -*-
require File.expand_path('../lib/baboon/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'baboon'
  s.version       = Baboon::VERSION
  s.executables   = %w[ baboon ]
  s.license       = 'MIT'
  s.homepage      = 'https://github.com/amanelis/baboon'
  
  s.authors       = ['Alex Manelis']
  s.email         = ['amanelis@gmail.com']
  s.description   = %q{A lite deployment package for rails applications.}
  s.summary       = %q{Add a configuration file, setup and deploy.}
  
  s.files = Dir['Rakefile', '{bin,lib,spec}/**/*', 'README*'] & `git ls-files`.split("\n")

  s.require_paths = ['lib']
  s.rubyforge_project = 'baboon'
  
  s.add_dependency 'thor'
  s.add_dependency 'net-ssh'
  s.add_dependency 'net-scp'
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rails'
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
