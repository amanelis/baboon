require 'spec_helper'

describe Baboon::Cli do
  before {
    $stdout.sync ||= true
    WebMock.disable_net_connect!(:allow_localhost => true)
  }
  
  describe 'console commands' do
    describe 'baboon help' do
      let(:output) { capture(:stdout) { subject.help } }
      
      it { should_not be_nil }
      it { expect(output).to include('Baboon commands') }
    end
    
    describe 'baboon configuration' do
      let(:output) { capture(:stdout) { subject.configuration } }
      
      it { should_not be_nil }
      it { expect(output).to include('Vacuum HQ') }
    end
  end
end 