#!/usr/bin/env rake
require "bundler/gem_tasks"

directory '.'
task :dgem => :environment do
  sh 'rm *.gem'
end

task :bgem => :environment do
  sh 'gem build *.gemspec'
end
