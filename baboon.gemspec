# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'baboon/version'

Gem::Specification.new do |s|
  s.name          = 'baboon'
  s.version       = Baboon::VERSION.dup
  s.executables   = %w[ baboon ]
  s.license       = 'MIT'
  s.homepage      = 'https://github.com/amanelis/baboon'

  s.authors       = ['Alex Manelis']
  s.email         = ['amanelis@gmail.com']
  s.description   = %q{A lite deployment package for rails applications.}
  s.summary       = %q{Add a configuration file, setup and deploy.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.1.0'

  s.add_dependency 'thor',            '~> 0.19.1'
  s.add_dependency 'net-ssh',         '~> 2.6'
  s.add_dependency 'net-ssh-session', '~> 0.1.6'
end
