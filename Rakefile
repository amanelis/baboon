#!/usr/bin/env rake

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

directory '.'
task :dgem do
  system 'rm *.gem'
end

task :bgem do
  system 'gem build *.gemspec'
end
