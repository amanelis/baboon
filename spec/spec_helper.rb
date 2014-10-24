require 'simplecov'
SimpleCov.start do
  add_group 'Baboon', 'lib/'
end

require 'yaml'
YAML::ENGINE.yamler = 'psych'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../lib/baboon', __FILE__)

Dir["spec/support/**/*.rb"].each { |f| require f }

PROJECT_ROOT = File.expand_path('../..', __FILE__)
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

require 'webmock/rspec'
require 'capybara/rspec'

RSpec.configure do |config|
  #config.color_enabled = true
  config.tty = true
  config.mock_with :rspec

  # Configure devise to work for authentication
  config.include WebMock::API

  # Capybara for integrations
  config.include Capybara::DSL

  # WebMock Configuration
  config.before do
   WebMock.enable!
     if Capybara.current_driver != :rack_test
       selenium_requests = %r{/((__.+__)|(hub/session.*))$}
       WebMock.disable_net_connect! :allow => selenium_requests
       WebMock.disable_net_connect! :allow => '127.0.0.1:#{Capybara.current_session.driver.server_port}' # this only works for capybara selenium and capybara-webkit
     else
       WebMock.disable_net_connect!
     end
  end

  # for connections where we need to have network access we just tag it network
  config.before(:each, :network => true) do
    WebMock.disable!
  end

  config.before(:each) do
    ARGV.clear
    $stdout.sync ||= true
  end

  # Captures the output for analysis later
  #
  # @example Capture `$stderr`
  #
  #     output = capture(:stderr) { $stderr.puts "this is captured" }
  #
  # @param [Symbol] stream `:stdout` or `:stderr`
  # @yield The block to capture stdout/stderr for.
  # @return [String] The contents of $stdout or $stderr
  def capture(stream)
   begin
     stream = stream.to_s
     eval "$#{stream} = StringIO.new"
     yield
     result = eval("$#{stream}").string
   ensure
     eval("$#{stream} = #{stream.upcase}")
   end

   result
  end

  # Silences the output stream
  #
  # @example Silence `$stdout`
  #
  #     silence(:stdout) { $stdout.puts "hi" }
  #
  # @param [IO] stream The stream to use such as $stderr or $stdout
  # @return [nil]
  alias :silence :capture
end
