require 'spec_helper'

module Scribbler
  describe Configurator do
    subject { Configurator }
    describe "logs" do
      before :each do
        subject.logs = nil
      end

      it "should let me set it" do
        new_logs = %w{1 2}
        subject.logs = new_logs
        subject.logs.should == new_logs
      end
    end

    describe "application_include" do
      it "get default" do
        subject.application_include.should == false
      end

      it "should let me set it" do
        subject.application_include = true
        subject.application_include.should == true
      end
    end
  end
end
