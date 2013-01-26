require 'simplecov'
SimpleCov.start do
  add_group 'Baboon', 'lib/'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../lib/baboon', __FILE__)

require 'rails/all'
require 'rails/test_help'

PROJECT_ROOT = File.expand_path('../..', __FILE__)
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.mock_with :rspec
end