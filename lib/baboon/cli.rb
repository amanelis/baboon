require 'baboon'
require 'baboon/configuration'
require 'baboon/logger'

require 'thor'
require 'net/ssh'

module Baboon
  class Error
    class << self
      def stop reason
        raise StandardError, reason
      end
    end
  end
  
  class Util
    class << self
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
    attr_accessor :logger, :configuration

    def initialize(*args)
      super
      @logger ||= Logger.new({level: 3, disable_formatters: false})
      
      $stdout.sync = true
      
      # Load the users baboon configuration
      if File.exists?("config/initializers/baboon.rb")
        @configuration = Util.read_configuration("config/initializers/baboon.rb")
        
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
        #Error.stop("Baboon says there is no configuration file at: config/initializers/baboon.rb. Please run `rails g baboon:install`")
        printf @logger.format("Baboon says there is no configuration file at config/initializers/baboon.rb, run the following command", "31", 1)
        printf @logger.format("USAGE: rails g baboon:install", "35", 1) 
      end
    end
    
    desc "deploy", "Starts a real deploy to a server"
    def deploy
      printf @logger.format("== Baboon starting deploy", "32", 1)
      
      # Loop through each server and do deploy, we will add threading later to do simultaneous deploys
      Baboon.configuration.servers.each do |server|     
        current = server.to_s.strip
        
        printf @logger.format("== [#{current}]", "35", 1) 
        
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
          host: current
        }
            
        Net::SSH.start(credentials[:host], credentials[:user]) do |session|
          instructions.each do |instruction|
            puts "[#{current}]: #{instruction}"
            puts ""
            session.exec instruction
            session.loop
          end
        end
      end # Looping servers
      
      printf @logger.format("== Baboon deploy Complete", "31", 1)
    end

    desc "configuration", "Shows the current configuration for baboon"
    def configuration
      printf @logger.format("Baboon[Application]: #{Baboon.configuration.application}", "37", 1)
      printf @logger.format("Baboon[Repository]: #{Baboon.configuration.repository}", "37", 1)
      printf @logger.format("Baboon[Deploy_path]: #{Baboon.configuration.deploy_path}", "37", 1)
      printf @logger.format("Baboon[Deploy_user]: #{Baboon.configuration.deploy_user}", "37", 1)
      printf @logger.format("Baboon[Branch]: #{Baboon.configuration.branch}", "37", 1)
      printf @logger.format("Baboon[Rails_env]: #{Baboon.configuration.rails_env}", "37", 1)
      printf @logger.format("Baboon[Servers]: #{Baboon.configuration.servers}", "37", 1)
    end
    
    desc "servers", "Shows the current servers that will get deployed to"
    def servers
      printf @logger.format(Baboon.configuration.servers.inspect, "31", 1)
    end

    # desc "init", "Generates deployment customization scripts for your app"
    # def init
    #   require 'generators/baboon/install/intall_generator'
    #   InstallGenerator::start([])
    # end
    # 
    # desc "restart", "Restarts the application on the server"
    # def restart
    #   run "cd #{deploy_to} && deploy/restart | tee -a log/deploy.log"
    # end
    # 
    # desc "rollback", "Rolls back the checkout to before the last push"
    # def rollback
    #   run "cd #{deploy_to} && git reset --hard ORIG_HEAD"
    #   invoke :restart
    # end
    # 
    # desc "log", "Shows the last part of the deploy log on the server"
    # method_option :tail, :aliases => '-t', :type => :boolean, :default => false
    # method_option :lines, :aliases => '-l', :type => :numeric, :default => 20
    # def log(n = nil)
    #   tail_args = options.tail? ? '-f' : "-n#{n || options.lines}"
    #   run "tail #{tail_args} #{deploy_to}/log/deploy.log"
    # end
    # 
    # desc "upload <files>", "Copy local files to the remote app"
    # def upload(*files)
    #   files = files.map { |f| Dir[f.strip] }.flatten
    #   abort "Error: Specify at least one file to upload" if files.empty?
    # 
    #   scp_upload files.inject({}) { |all, file|
    #     all[file] = File.join(deploy_to, file)
    #     all
    #   }
    # end
  end
end
