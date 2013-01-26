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
        
        Baboon.configure do |config|
          config.application  = @configuration[:application]
          config.repository   = @configuration[:repository]
          config.releases     = @configuration[:releases]
          config.deploy_path  = @configuration[:deploy_path]
          config.deploy_user  = @configuration[:deploy_user]
          config.branch       = @configuration[:branch]
          config.rails_env    = @configuration[:rails_env]
          config.servers      = @configuration[:servers]
        end
      else
        Error.stop("Baboon says there is no configuration file at: config/initializers/baboon.rb. Please run `rails g baboon:install`")
      end
    end
    
    desc "deploy", "Starts a real deploy to a server"
    def deploy
      printf @logger.format(" == Baboon starting deploy", "32", 1)
      
      # Essentially these are the instructions we need run for the Ubuntu 11.04
      instructions = [
        "cd #{Baboon.configuration.deploy_path} && bundle install",
        "cd #{Baboon.configuration.deploy_path} && git fetch",
        "cd #{Baboon.configuration.deploy_path} && git checkout #{Baboon.configuration.branch.to_s}",
        "cd #{Baboon.configuration.deploy_path} && git merge origin/#{Baboon.configuration.branch.to_s}",
        "cd #{Baboon.configuration.deploy_path} && touch tmp/restart.txt"
      ]
      
      # Vars for connecting via ssh to the server
      credentials = { 
        user: Baboon.configuration.deploy_user.to_s, 
        host: 'ec2-50-19-131-228.compute-1.amazonaws.com'
      }
            
      Net::SSH.start(credentials[:host], credentials[:user]) do |session|
        instructions.each do |instruction|
          puts "instruction executing: #{instruction}"
          puts ""
          session.exec instruction
          session.loop
        end
      end
      
      printf @logger.format(" == Baboon deploy Complete", "31", 1)
    end

    desc "configuration", "Shows the current configuration for baboon"
    def configuration
      printf @logger.format("Baboon[Application]: #{Baboon.configuration.application}", "37", 1)
      printf @logger.format("Baboon[Repository]: #{Baboon.configuration.repository}", "37", 1)
      printf @logger.format("Baboon[Releases]: #{Baboon.configuration.releases}", "37", 1)
      printf @logger.format("Baboon[Deploy_path]: #{Baboon.configuration.deploy_path}", "37", 1)
      printf @logger.format("Baboon[Deploy_user]: #{Baboon.configuration.deploy_user}", "37", 1)
      printf @logger.format("Baboon[Branch]: #{Baboon.configuration.branch}", "37", 1)
      printf @logger.format("Baboon[Rails_env]: #{Baboon.configuration.rails_env}", "37", 1)
      printf @logger.format("Baboon[Servers]: #{Baboon.configuration.servers}", "37", 1)
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
