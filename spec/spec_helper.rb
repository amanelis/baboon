require 'simplecov'
SimpleCov.start do
  add_group 'Baboon', 'lib/'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../lib/baboon', __FILE__)

Dir["spec/support/**/*.rb"].each { |f| require f }

PROJECT_ROOT = File.expand_path('../..', __FILE__)
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

$:.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

RSpec.configure do |config|
  config.color_enabled = true
  config.tty = true
  config.mock_with :rspec
  
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