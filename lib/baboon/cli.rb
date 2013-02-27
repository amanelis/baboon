require 'baboon'
require 'baboon/configuration'
require 'baboon/logger'

require 'find'
require 'net/ssh'
require 'thor'

module Baboon
  class Error
    class << self
      # stop
      # @param:
      # @return: StandardError class, will halt execution of program
      def stop reason
        raise StandardError, reason
      end
    end
  end
  
  class Util
    class << self
      # file_check!
      # @param: String file path
      # @return: Boolean || String depending on if file is found
      def file_check! file
        return false if file.nil? || !file
      end
      
      # locate_file
      # Will try and locate the baboon.rb file it it does not exist. Great method
      # used especially for testing Baboon.
      # @param:
      # @return: String[file path, used to locate and initialize the configuration file]
      def locate_file
        config_file = ''
        default_baboon_file_path = "config/initializers/baboon.rb"
        if File.exists?(default_baboon_file_path)
          config_file = default_baboon_file_path
        else
          Find.find('.') do |path|
            if path.include?('baboon.rb') 
              next unless File.open(path, &:readline).include?('Baboon.configure do |config|')
              config_file = path
              break
            end
          end
        end
        config_file
      end
      
      # read_configuration
      # This will attempt to read the configuration file, only need until after the file
      # is found in the application.
      # @param: String[file path, relative to the directory of the configuration]
      # @return: Hash[configuration options in the config file, use these to set Baboon.configuration]
      def read_configuration(file)
        configuration = []
        line_number = 0
        text = File.open(file).read
        text.gsub!(/\r\n?/, '\n')

        text.each_line do |line|
          next if line.include?('Baboon.configure')
          next if line.include?('end')
          line.gsub!(/^(.*)\s=\s/, '')
          line.gsub!('\'', '')
          line.strip!
          
          configuration << { BABOON_CONFIGURATION_OPTIONS[line_number] => line }
          line_number += 1
        end
        
        return configuration.reduce({}, :merge)
      end
    end
  end
  
  class Cli < Thor
    # @logger: call an instance of the logger class, use throughout baboon
    # @configuration: holds the default baboon configuration set in config file
    # @configuration_file: the exact file location of baboon configuration
    attr_accessor :logger, :configuration, :configuration_file, :stop

    # initialize
    # @param: Array
    # @ereturn: instance
    def initialize(*args)
      super
      $stdout.sync ||= true
      @logger ||= Logger.new({level: 3, disable_formatters: false})
      
      # Attempt to locate the configuration file in the project if it was not set.
      @configuration_file = Util.locate_file
      
      # Return if file not found
      if @configuration_file.nil? ||  @configuration_file == ''
        printf "#{BABOON_TITLE}\n"
        printf "  \033[22;31mError:\033[22;37m no configuration file is present anywhere in the application or at config/initializers/baboon.rb\n"
        printf "  \033[01;32mUsage:\033[22;37m rails g baboon:install\n"
        @stop = true
        return
      end
      
      # Load the users baboon configuration
      if File.exists?(@configuration_file) # tad redundant
        @configuration = Util.read_configuration(@configuration_file)
        
        # configure the servers
        Baboon.configure do |config|
          config.application  = @configuration[:application]
          config.repository   = @configuration[:repository]
          config.deploy_path  = @configuration[:deploy_path]
          config.deploy_user  = @configuration[:deploy_user]
          config.branch       = @configuration[:branch]
          config.rails_env    = @configuration[:rails_env]
          config.servers      = @configuration[:servers].gsub('[', '').gsub(']', '').split(',').collect(&:strip)
        end      
      else
        printf "#{BABOON_TITLE}\n"
        printf "  \033[22;31mError:\033[22;37m no configuration file is present anywhere in the application or at config/initializers/baboon.rb\n"
        printf "  \033[01;32mUsage:\033[22;37m rails g baboon:install\n"
        @stop = true
        return
      end
    end
    
    desc "deploy", "Deploys the application to the configured servers."
    def deploy
      return if @stop      
            
      # Loop through each server and do deploy, we will add threading later to do simultaneous deploys
      Baboon.configuration.servers.each do |server|     
        host = server.to_s.strip
              
        # Essentially these are the instructions we need run for the Ubuntu 11.04 for rails
        # TODO: add lib of different instruction sets for Play framework, nodejs, etc
        instructions = [
          "cd '#{Baboon.configuration.deploy_path}' && git fetch",
          "cd '#{Baboon.configuration.deploy_path}' && git checkout #{Baboon.configuration.branch.to_s}",
          "cd '#{Baboon.configuration.deploy_path}' && git merge origin/#{Baboon.configuration.branch.to_s}",
          "cd '#{Baboon.configuration.deploy_path}' && bundle install --deployment",
          "cd '#{Baboon.configuration.deploy_path}' && touch tmp/restart.txt"
        ]
      
        # Vars for connecting via ssh to the server
        credentials = { 
          user: Baboon.configuration.deploy_user.to_s, 
          host: host
        }
            
        Net::SSH.start(credentials[:host], credentials[:user]) do |session|
          instructions.each do |instruction|
            printf "[#{host}]: #{instruction}\n"
            session.exec instruction
            session.loop
          end
        end
      end # Looping servers      
    end # def deploy

    desc "configuration", "Shows the current configuration for baboon."
    def configuration    
      return if @stop
      
      printf @logger.format("#{BABOON_TITLE}[Application]: #{Baboon.configuration.application}", "37", 1)
      printf @logger.format("#{BABOON_TITLE}[Repository]: #{Baboon.configuration.repository}", "37", 1)
      printf @logger.format("#{BABOON_TITLE}[Deploy_path]: #{Baboon.configuration.deploy_path}", "37", 1)
      printf @logger.format("#{BABOON_TITLE}[Deploy_user]: #{Baboon.configuration.deploy_user}", "37", 1)
      printf @logger.format("#{BABOON_TITLE}[Branch]: #{Baboon.configuration.branch}", "37", 1)
      printf @logger.format("#{BABOON_TITLE}[Rails_env]: #{Baboon.configuration.rails_env}", "37", 1)
      printf @logger.format("#{BABOON_TITLE}[Servers]: #{Baboon.configuration.servers}", "37", 1)
    end
  end
end