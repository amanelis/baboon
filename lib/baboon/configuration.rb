require 'baboon'

module Baboon
  # Baboon.configuration => output of configuration options
  class << self
    attr_accessor :configuration
  end

  # This method should be called with a block, even though none are given
  # in the parameters of the method
  def self.configure
    self.configuration ||= Configuration.new
    yield configuration
  end

  class Configuration
    def initialize
      # Cannot call attr inside of class, need to class_eval it
      class << self
        self
      end.class_eval do
        # Define all of the attributes
        BABOON_CONFIGURATION_OPTIONS.each do |name|
          attr_accessor name

          # For each given symbol we generate accessor method that sets option's
          # value being called with an argument, or returns option's current value
          # when called without arguments
          define_method name do |*values|
            value = values.first
            value ? self.send("#{name}=", value) : instance_variable_get("@#{name}")
          end
        end
      end
      # Initialize defaults
    end # initialize
  end # class Configuration
end # module Baboon