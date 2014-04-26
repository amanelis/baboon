require 'spec_helper'

describe Baboon do
  context 'application constants' do
    context 'title' do
      subject { BABOON_TITLE }
      it { expect(subject).to eq("\033[22;31mB\033[22;35ma\033[22;36mb\033[22;32mo\033[01;31mo\033[01;33mn\033[22;37m") }
    end

    context 'environment settings' do
      subject { BABOON_ENVIRONMENT_SETTINGS }
      it { expect(subject).to eq(['branch', 'deploy_path', 'deploy_user', 'rails_env', 'servers']) }
    end
  end
end
