# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'baboon/version'

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

  s.add_runtime_dependency 'thor',    '~> 0.19.1'
  s.add_runtime_dependency 'net-ssh', '~> 2.6'
  s.add_runtime_dependency 'net-ssh-shell'

  #s.add_development_dependency 'rake'
  #s.add_development_dependency 'rails'
  #s.add_development_dependency 'rspec'
  #s.add_development_dependency 'rspec-core'
  #s.add_development_dependency 'rspec-mocks'
  #s.add_development_dependency 'rspec-rails'
  #s.add_development_dependency 'rspec-expectations'
  #s.add_development_dependency 'shoulda-matchers'
  #s.add_development_dependency 'simplecov'
  #s.add_development_dependency 'webmock'
  #s.add_development_dependency 'capybara'
  #s.add_development_dependency 'faker'
  #s.add_development_dependency 'coveralls'
end
