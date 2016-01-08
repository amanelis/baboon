require 'spec_helper'

describe Baboon::Util do
  describe '.locate_baboon_configuration_file' do
    context 'will always return at least one path' do
      it {
        expect(Baboon::Util.locate_baboon_configuration_file).to include('lib/generators/baboon/install/templates/baboon.yml')
      }
    end
  end
end
