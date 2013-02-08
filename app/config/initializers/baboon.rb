Baboon.configure do |config|
  config.application = 'console'
  config.repository  = 'git@github.com:128lines/console.fm.git'
  config.deploy_path = '/home/rails/console.fm/'
  config.deploy_user = :rails
  config.branch      = :master
  config.rails_env   = :production
  config.servers     = ['10.0.0.1', '10.0.0.1']
end