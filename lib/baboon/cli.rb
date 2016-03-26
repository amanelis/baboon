require 'baboon'
require 'baboon/util'

require 'net/ssh'
require 'net/ssh/session'
require 'find'
require 'thor'
require 'yaml'

module Baboon
  class InvalidConfigurationError < StandardError
  end

  class SSHError < StandardError
  end

  class Cli < Thor
    # Name the package output
    package_name "Baboon"

    # @configuration: holds the default baboon configuration set in config file
    # @configuration_file: the exact file location of baboon configuration
    attr_accessor :configuration, :configuration_file, :errors, :stop

    # initialize
    # @param: Array
    # @return: instance
    def initialize *args
      super

      # Sync stdout for when communicating over ssh channel
      $stdout.sync ||= true

      # Store any errors here during the process so they can be printed to STDOUT
      @errors = []

      # Attempt to locate the configuration file in the project if it was not set.
      @configuration_file = Util.locate_baboon_configuration_file

      # Return if file not found
      if @configuration_file.nil?
        printf "#{BABOON_TITLE}\n"
        printf "  \033[22;31mError:\033[22;37m no configuration file is present anywhere in the application or at config/baboon.yml\n"
        printf "  \033[01;32mUsage:\033[22;37m rails g baboon:install\n"
        errors << "#initialize: failed to load a valid configuration file, please be sure a proper one is created at config/baboon.yml"
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
            errors << "#initialize: incorrect key:val [#{key}:#{k}] pair in config/baboon.yml"
            @stop = true
            return
          end
        end
      end
    end

    desc "deploy [ENVIRONMENT]", "Deploys the application to the configured servers via ssh."
    def deploy environment
      check_configuration!(environment)



      # Get the current config for this environment
      current_environment_configuration = @configuration['baboon']['environments'][environment]

      # Loop through the servers
      current_environment_configuration['servers'].each do |host|
        printf "Deploying[#{host}]\n"

        # TODO: add lib of different instruction sets for Play framework, nodejs, etc
        instructions = [
          "cd '#{current_environment_configuration['deploy_path']}' && git fetch",
          "cd '#{current_environment_configuration['deploy_path']}' && git checkout #{current_environment_configuration['branch']}",
          "cd '#{current_environment_configuration['deploy_path']}' && git merge origin/#{current_environment_configuration['branch']}",
          "cd '#{current_environment_configuration['deploy_path']}' && RAILS_ENV=#{current_environment_configuration['rails_env']} bundle install --deployment --without development test",
          "cd '#{current_environment_configuration['deploy_path']}' && RAILS_ENV=#{current_environment_configuration['rails_env']} bundle exec rake assets:precompile",
          "cd '#{current_environment_configuration['deploy_path']}' && RAILS_ENV=#{current_environment_configuration['rails_env']} bundle exec rake db:migrate"
        ]

        if current_environment_configuration.has_key?('restart_command') && !current_environment_configuration['restart_command'].nil?
          instructions << current_environment_configuration['restart_command']
        else
          instructions << "cd '#{current_environment_configuration['deploy_path']}' && touch tmp/restart.txt"
        end

        # Vars for connecting via ssh to the server
        credentials = {
          user: current_environment_configuration['deploy_user'],
          host: host
        }

        # Initialize the SSH class
        session = Net::SSH::Session.new(credentials[:host], credentials[:user], nil)

        # Open the session
        session.open

        # Set the rails_env session if var is present
        session.export_hash(
          'RAILS_ENV' => current_environment_configuration['rails_env'],
          'RACK_ENV'  => current_environment_configuration['rails_env']
        )

        # Check if user has added the callbacks block
        can_run_callbacks = current_environment_configuration.has_key?('callbacks')

        # Run pre instructions
        if can_run_callbacks
          pre_callbacks = current_environment_configuration['callbacks']['before_deploy']

          if !pre_callbacks.nil? && pre_callbacks.is_a?(Array) && pre_callbacks.count >= 1
            printf "[\033[36m#{host}\033[0m]: Running pre callbacks...\n"
            run_commands(host, session, pre_callbacks)
          end
        end

        # Execute commands
        run_commands(host, session, instructions)

        # Run post instructions
        if can_run_callbacks
          post_callbacks = current_environment_configuration['callbacks']['after_deploy']

          if !post_callbacks.nil? && post_callbacks.is_a?(Array) && post_callbacks.count >= 1
            printf "[\033[36m#{host}\033[0m]: Running post callbacks...\n"
            run_commands(host, session, post_callbacks)
          end
        end

        # Close and exit the session
        begin
          session.exit
        rescue => e
          # Here well want to write to stdout if --debug flag was passed
        end

        printf "[\033[36m#{host}\033[0m]: \033[32mComplete!\033[0m\n"
      end
    end

    desc "fetch", "Fetches a given file from your project's directory"
    def fetch environment, file
      current_configuration = @configuration['baboon']['environments'][environment]

      raise InvalidHostError.new("No host found in your configuration, please add one") if current_configuration['servers'].first.nil?

      host = current_configuration['servers'].first

      # Initialize the SSH class
      session = Net::SSH::Session.new(current_configuration['servers'].first, current_configuration['deploy_user'], nil)
      session.open

      file_path = file.gsub(/^\//, '')
      printf "[\033[36m#{host}\033[0m]: Fetching file '#{file_path}'\n"
      fetch_result = session.run("/bin/cat #{current_configuration['deploy_path']}/#{file_path}")
      session.exit

      printf "[\033[36m#{host}\033[0m]: Results below.\n"
      printf fetch_result.output + "\n"
      printf "[\033[36m#{host}\033[0m]: Complete.\n"
    end

    desc "ref", "Current git ref HEAD of the running code"
    def ref
      current_configuration = @configuration['baboon']['environments'][environment]


    end

    desc "rollback", "Rollsback the application to a given state via ssh."
    def rollback environment
      puts "This functionality has not been implemented yet, coming soon, I promise :)"
    end

    desc "configuration", "Shows the current configuration for baboon."
    def configuration
      puts @configuration['baboon']['application']
    end

    desc "version", "Shows the version of Baboon."
    def version
      puts Baboon::VERSION
    end

  private

    #
    # check_configuration
    #
    # Pass the environment to check if the configuration is valid. If not, this
    # method will print to stdout and raise an error.
    #
    # @params: String(envrionment)
    # @returns: nil
    def check_configuration!(environment)
      if !@configuration['baboon']['environments'].has_key?(environment)
        printf "#{BABOON_TITLE}\n"
        printf "  \033[22;31mError:\033[22;37m looks like you typed an incorrect key for an environment you specified in your baboon.yml file\n"
        printf "  \033[01;32mUsage:\033[22;37m try one of these #{@configuration['baboon']['environments'].keys}\n"

        raise InvalidConfigurationError.new("Your configuration is invalid, please check if you have misssss spelled something.")
      end
    end

    #
    # run_commands
    #
    # Processes a command remotely on a host via the ssh session library.
    #
    # @params: String(host), Net::SSH::Session(session), Array(instructions)
    # @returns: nil
    def run_commands(host, session, instructions)
      begin
        session.run_multiple(instructions) do |cmd|
          printf "[\033[36m#{host}\033[0m]: #{cmd}\n"
        end
      rescue => e
        raise SSHError.new("There was an error executing a remote command on [#{host}] -> '#{e.inspect}'")
      end
    end
  end
end
