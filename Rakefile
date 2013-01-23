#!/usr/bin/env rake
require "bundler/gem_tasks"

directory '.'
task :dgem do
  sh 'rm *.gem'
end

task :bgem do
  sh 'gem build *.gemspec'
end
