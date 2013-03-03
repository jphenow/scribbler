require 'spec_helper'

module Rails; end
module Scribbler
  describe Configurator do
    describe "logs" do
      it "lets me set logs" do
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

    describe "default template" do
      its(:template) { should be_a Proc }
    end

    describe "log directory" do
      let(:root_stub) { double }
      before do
        Rails.stub :root => root_stub
      end

      after do
        Rails.rspec_reset
      end

      it "tries a rails root when Rails defined" do
        root_stub.should_receive(:join).with 'log'
        subject.log_directory
      end

      it "falls back to pwd/log without rails" do
        subject.log_directory = nil #RESET
        Rails.should_receive(:root).and_raise(NameError)
        subject.log_directory.should == "#{Dir.pwd}/log"
      end

      it "sets the log directory" do
        var_log = File.new "/var/log"
        subject.log_directory = var_log
        subject.log_directory.should == var_log
        subject.log_directory = nil

        # Check the reset
        Rails.should_receive(:root).and_raise(NameError)
        Dir.should_receive(:pwd).and_return('dir')
        subject.log_directory.should == 'dir/log'
        subject.log_directory
      end
    end
  end
end
