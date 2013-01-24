require 'simplecov'
SimpleCov.start do
  add_group 'Baboon', 'lib/'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../lib/baboon', __FILE__)

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
end
