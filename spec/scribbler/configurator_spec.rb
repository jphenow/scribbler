require 'spec_helper'

module Scribbler
  describe Configurator do
    subject { Configurator }
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

    describe "log directory" do
      it "tries a rails root when Rails defined" do
        root_stub = stub
        root_stub.should_receive(:join).with 'log'
        Rails = stub(:root => root_stub)
        subject.log_directory
      end

      it "falls back to pwd/log without rails" do
        dir = "dir/"
        Rails.should_receive(:root).and_raise(NameError)
        Dir.should_receive(:pwd).and_return('dir')
        subject.log_directory.should == 'dir/log'
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
