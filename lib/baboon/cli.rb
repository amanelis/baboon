require 'thor'
require 'net/ssh'
require 'net/scp'

module Baboon
  class Cli < Thor
    desc "init", "Generates deployment customization scripts for your app"
    def init
      require 'generators/baboon/install/intall_generator'
      InstallGenerator::start([])
    end
    
    desc "restart", "Restarts the application on the server"
    def restart
      run "cd #{deploy_to} && deploy/restart | tee -a log/deploy.log"
    end

    desc "rollback", "Rolls back the checkout to before the last push"
    def rollback
      run "cd #{deploy_to} && git reset --hard ORIG_HEAD"
      invoke :restart
    end
    
    desc "log", "Shows the last part of the deploy log on the server"
    method_option :tail, :aliases => '-t', :type => :boolean, :default => false
    method_option :lines, :aliases => '-l', :type => :numeric, :default => 20
    def log(n = nil)
      tail_args = options.tail? ? '-f' : "-n#{n || options.lines}"
      run "tail #{tail_args} #{deploy_to}/log/deploy.log"
    end

    desc "upload <files>", "Copy local files to the remote app"
    def upload(*files)
      files = files.map { |f| Dir[f.strip] }.flatten
      abort "Error: Specify at least one file to upload" if files.empty?

      scp_upload files.inject({}) { |all, file|
        all[file] = File.join(deploy_to, file)
        all
      }
    end
  end
end