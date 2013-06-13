require 'baboon'
require 'baboon/configuration'
require 'baboon/util'

require 'find'
require 'net/ssh'
require 'thor'
require 'yaml'

module Baboon  
  class Cli < Thor
    # Name the package output
    package_name "Baboon"
    
    # @logger: call an instance of the logger class, use throughout baboon
    # @configuration: holds the default baboon configuration set in config file
    # @configuration_file: the exact file location of baboon configuration
    attr_accessor :configuration, :configuration_file, :stop

    # initialize
    # @param: Array
    # @ereturn: instance
    def initialize *args
      super
      $stdout.sync ||= true
      
      # Set our yaml engine
      YAML::ENGINE.yamler = 'syck'
      
      # Attempt to locate the configuration file in the project if it was not set.
      @configuration_file = Util.locate_file
      
      # Return if file not found
      if @configuration_file.nil? ||  @configuration_file == ''
        printf "#{BABOON_TITLE}\n"
        printf "  \033[22;31mError:\033[22;37m no configuration file is present anywhere in the application or at config/baboon.yml\n"
        printf "  \033[01;32mUsage:\033[22;37m rails g baboon:install\n"
        @stop = true  
        return
      end
      
      # Load the file now that we know its not nil
      @configuration = YAML.load_file(@configuration_file)
      
      # Double check that configuration is setup properly
      if @configuration['baboon'].has_key?('environments')
        @configuration['baboon']['environments'].map do |environment|
          hash = Hash[*environment]
          key  = hash.keys.first
          
          # Must have all defined keys filled out
          unless BABOON_ENVIRONMENT_SETTINGS.collect { |k| hash[key].has_key?(k) }.all?
            printf "#{BABOON_TITLE}\n"
            printf "  \033[22;31mError:\033[22;37m incorrect settings for the \"#{key}\" in config/baboon.yml\n"
            printf "  \033[01;32mUsage:\033[22;37m rails g baboon:install\n"
            @stop = true
            return
          end
        end
      end
    end
    
    desc "deploy ENVIRONMENT", "Deploys the application to the configured servers."
    def deploy environment
      return if @stop   
      
      # Double checked the user typed the correct key
      unless @configuration['baboon']['environments'].has_key?(environment)
        printf "#{BABOON_TITLE}\n"
        printf "  \033[22;31mError:\033[22;37m looks like you typed an incorrect key for an environment you specified in your baboon.yml file\n"
        printf "  \033[01;32mUsage:\033[22;37m try one of these #{@configuration['baboon']['environments'].keys}\n"
        @stop = true
        return
      end
      
      # Get the current config for this environment
      current_environment_configuration = @configuration['baboon']['environments'][environment]
      
      # Loop through the servers
      current_environment_configuration['servers'].each do |host|
        printf "Deploying[#{host}]"
        printf ""
        
        # TODO: add lib of different instruction sets for Play framework, nodejs, etc
        instructions = [
          "cd '#{current_environment_configuration['deploy_path']}' && git fetch",
          "cd '#{current_environment_configuration['deploy_path']}' && git checkout #{current_environment_configuration['branch']}",
          "cd '#{current_environment_configuration['deploy_path']}' && git merge origin/#{current_environment_configuration['branch']}",
          "cd '#{current_environment_configuration['deploy_path']}' && bundle install --deployment",
          "cd '#{current_environment_configuration['deploy_path']}' && touch tmp/restart.txt"
        ]
        
        # Vars for connecting via ssh to the server
        credentials = { 
          user: current_environment_configuration['deploy_user'], 
          host: host
        }
        
        # Start the connection and excute command
        Net::SSH.start(credentials[:host], credentials[:user]) do |session|
          instructions.each do |instruction|
            printf "[#{host}]: #{instruction}\n"
            session.exec instruction
            session.loop
          end
        end
      end   
    end # def deploy

    desc "configuration", "Shows the current configuration for baboon."
    def configuration    
      return if @stop
      puts @configuration.inspect
    end
  end
end