require 'spec_helper'

describe Baboon::Util do
  describe '.file_check!' do
    context 'checks if a file is nil' do
      it {
        expect(Baboon::Util.file_check!('lib/generators/baboon/install/templates/baboon.yml')).to eq(true)
      }
    end
  end

  describe '.locate_baboon_configuration_file' do
    context 'will always return at least one path' do
      it {
        expect(Baboon::Util.locate_baboon_configuration_file).to include('lib/generators/baboon/install/templates/baboon.yml')
      }
    end
  end
end
