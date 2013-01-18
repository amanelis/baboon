Baboon.configure do |config|
  config.application  = 'NAME OF YOUR APPLICATION'
  config.repository   = 'git@github.com:{some-project}.git'
  config.releases     = 5
  config.deploy_path  = '{path_to_application_on_server}'
  config.deploy_user  = :rails
  config.branch       = :master
  config.rails_env    = :production
  config.servers      = ['server_1', 'server_2']
end