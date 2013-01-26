require 'spec_helper'

describe Baboon do
  it "should have a valid CONFIGURATION HASH" do
    BABOON_CONFIGURATION_OPTIONS.should_not be_nil
  end
end