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
end
