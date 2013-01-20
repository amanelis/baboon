# Standard configuration options for Baboon
#
# These options are important at this location. Change here and they
# are persisted throughout the entire Baboon configuration and as well
# as the config initializer baboon.rb file that is generated in the
# standing Rails application.
# 
# option[:application]  String  => Has no berrance to the deployment, call it whatever.
# option[:repository]   String  => For now baboon only supports Git. This should be the actual Git repository of the application baboon will deploy.
# option[:releases]     Integer => As of right now releases does not control how many releases are stored, baboon is just doing a rollback scheme.
# option[:deploy_path]  String  => The actual deploy path the application will sit at on the server. Exactly where the app's .git/ folder would be.
# option[:deploy_user]  String/Symbol   => The user baboon will be authenticating with on the server. Should have your key stored for optimal authentication.
# option[:branch]       String/Symbol   => The branch on your repository baboon will be pulling from.
# option[:rails_env]    String/Symbol   => For rake tasks to be run properly on your server, baboon needs to know what env it will be running on your server.
# option[:server]       Array[String]   => This will be an array of ip addresses of the servers baboon will deploy to.
BABOON_CONFIGURATION_OPTIONS = [
  :application,       # => This will be the name of the Application - not the directory
  :repository,        # => This will be the :scm of the repository the application will be cloning
  :releases,          # => Number of releases we will hold as a copy on the system
  :deploy_path,       # => This will be the actual deploy path of the application, should have /home/#{user}/app
  :deploy_user,       # => This will be the user the system will authenticate with to do the deploy, should have sudo
  :branch,            # => Branch we will be cloning from on GIT
  :rails_env,         # => The rails environment the sever will be running
  :servers            # => An array of servers baboon will push to
]

require 'baboon/configuration'
require 'baboon/cli'
require 'baboon/logger'
require 'baboon/version'