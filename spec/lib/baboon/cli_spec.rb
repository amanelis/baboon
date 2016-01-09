require 'spec_helper'
require 'pry'
require 'json'

describe Baboon::Cli do
  before {
    $stdout.sync ||= true
    WebMock.disable_net_connect!(allow_localhost: true)
    allow(Baboon::Util).to receive(:locate_baboon_configuration_file).and_return("spec/baboon.yml")
  }
  
  describe 'console commands' do
    describe 'baboon help' do
      let(:output) { capture(:stdout) { subject.help }.strip }
      
      it { should_not be_nil }
      it { expect(output).to include('Baboon commands') }
    end
    
    describe 'baboon configuration' do
      let(:output) { capture(:stdout) { subject.configuration }.strip }
      
      it { should_not be_nil }
      it { expect(output).to eq('Baboon') }
    end

    describe 'baboon deploy {environment}' do
      let(:export_hash) {{ 'RAILS_ENV' => 'test', 'RACK_ENV' => 'test' }}
      let(:ssh_connection) { double("SSH Connection", open: true, exit: true, export_hash: export_hash, run_multiple: true) }

      before {
        allow(Net::SSH::Session).to receive(:new).and_return(ssh_connection)
        #expect(ssh_connection).to receive(:run_multiple).with(kind_of(Array))
        #expect(subject).to receive(:run_commands)
      }

      let(:output) { capture(:stdout) { subject.send(:deploy, 'staging') }.strip }

      it { should_not be_nil }
      it { expect(output).to include('Deploying[localhost]') }
    end
  end
end 
