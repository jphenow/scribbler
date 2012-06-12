require 'spec_helper'

module Scribbler
  describe 'version' do
    it "should have a version" do
      Scribbler::VERSION.should_not be_nil
    end
  end
end
