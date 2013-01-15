module Baboon
  # These are ment to be defined by the user as options
  # TODO: optimize, might want to define these on a better more
  #   dynamic pattern later on
  CONFIGURATION_OPTIONS = [
    :application,       # => This will be the name of the Application - not the directory
    :repository,        # => This will be the :scm of the repository the application will be cloning
    :releases,          # => Number of releases we will hold as a copy on the system
    :deploy_path,       # => This will be the actual deploy path of the application, should have /home/#{user}/app
    :deploy_user,       # => This will be the user the system will authenticate with to do the deploy, should have sudo
    :branch,            # => Branch we will be cloning from on GIT
    :rails_env
  ]

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
      class <<self
        self
      end.class_eval do
        # Define all of the attributes
        CONFIGURATION_OPTIONS.each do |name|
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