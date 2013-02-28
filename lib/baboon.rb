# Standard configuration options for Baboon
#
# These options are important at this location. Change here and they
# are persisted throughout the entire Baboon configuration and as well
# as the config initializer baboon.rb file that is generated in the
# standing Rails application.

# Nicely formatted output of the Baboon title
BABOON_TITLE = "\033[22;31mB\033[22;35ma\033[22;36mb\033[22;32mo\033[01;31mo\033[01;33mn\033[22;37m"
BABOON_ENVIRONMENT_SETTINGS = ['branch', 'deploy_path', 'deploy_user', 'rails_env', 'servers']

require 'baboon/configuration'
require 'baboon/cli'
require 'baboon/logger'
require 'baboon/version'