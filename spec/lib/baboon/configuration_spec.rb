require 'spec_helper'

describe Baboon::Configuration do
  describe 'configuration object should respond accordingly if not configured' do
    before do
      Baboon.configure do |config|
        config.application = nil
        config.repository  = nil
        config.deploy_path = nil
        config.deploy_user = nil
        config.branch      = nil
        config.rails_env   = nil
        config.servers     = nil
      end
    end
    
    context 'when nothing is given for application' do
      it 'should not be nil' do
        Baboon.configuration.application.should == nil
      end
    end
    
    context 'when nothing is given for repository' do
      it 'should not be nil' do
        Baboon.configuration.repository.should == nil
      end
    end
    
    context 'when nothing is given for deploy_path' do
      it 'should not be nil' do
        Baboon.configuration.deploy_path.should == nil
      end
    end
    
    context 'when nothing is given for deploy_user' do
      it 'should not be nil' do
        Baboon.configuration.deploy_user.should == nil
      end
    end
    
    context 'when nothing is given for branch' do
      it 'should not be nil' do
        Baboon.configuration.branch.should == nil
      end
    end
    
    context 'when nothing is given for rails_env' do
      it 'should not be nil' do
        Baboon.configuration.rails_env.should == nil
      end
    end
    
    context 'when nothing is given for servers' do
      it 'should not be nil' do
        Baboon.configuration.servers.should == nil
      end
    end
  end
  
  describe 'configuration object should respond accordingly if is configured' do
    before do
      Baboon.configure do |config|
        config.application = 'console'
        config.repository  = 'git@github.com:128lines/console.fm.git'
        config.deploy_path = '/home/rails/console.fm/'
        config.deploy_user = :rails
        config.branch      = :master
        config.rails_env   = :production
        config.servers     = ['server_1', 'server_2']
      end
    end
    
    context 'when a application is assigned' do
      it 'should not be nil' do
        Baboon.configuration.application.should eq('console')
      end
    end
    
    context 'when a repository is assigned' do
      it 'should not be nil' do
        Baboon.configuration.repository.should eq('git@github.com:128lines/console.fm.git')
      end
    end
    
    context 'when a deploy_path is assigned' do
      it 'should not be nil' do
        Baboon.configuration.deploy_path.should eq('/home/rails/console.fm/')
      end
    end
    
    context 'when a deploy_user is assigned' do
      it 'should not be nil' do
        Baboon.configuration.deploy_user.should eq(:rails)
      end
    end
    
    context 'when a branch is assigned' do
      it 'should not be nil' do
        Baboon.configuration.branch.should eq(:master)
      end
    end
    
    context 'when a rails_env is assigned' do
      it 'should not be nil' do
        Baboon.configuration.rails_env.should eq(:production)
      end
    end
    
    context 'when a server is assigned' do
      it 'should not be nil' do
        Baboon.configuration.servers.should eq(['server_1', 'server_2'])
      end
    end
  end
end