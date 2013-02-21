require 'spec_helper'

module ::Rails; end
module Scribbler
  describe Logger do
    before do
      Time.stub :now => "now"
    end

    describe "apply to log" do
      before do
        Scribbler.configure do |config|
          config.logs = %w[test_log]
        end
      end

      after do
        Scribbler.instance_variable_set "@config", nil
      end

      it "should not work without location" do
        subject.send(:apply_to_log, nil, :message => "...").should be_nil
      end

      it "should not work without message" do
        subject.should_not_receive :test_log_log_location
        subject.send(:apply_to_log, :test_log).should be_nil
      end

      it "should build a template and try to put it in a file" do
        options = { :message => "..." }
        file = mock(:puts => true)
        subject.should_receive(:build_with_template).with options
        subject.should_receive(:log_at).with :test_log
        File.should_receive(:open).and_yield(file)
        subject.send :apply_to_log, :test_log, options
      end

      it "doesn't find a file method" do
        # in case we have bad config data lingering
        subject.stub(:respond_to?).with('test_log_log_location').and_return false
        subject.should_not_receive(:test_log_log_location)
        Rails.should_receive(:root).and_raise(NameError)
        subject.log_at(:test_log).should == "#{subject.send(:config).log_directory}/test_log.log"
      end
    end

    describe "build with template" do
      let(:some_object) { stub(:id => "no id", :class => stub(:name => "SomeObject")) }
      before :each do
        Scribbler.configure do |config|
          config.application_include = false
        end
      end

      after :each do
        Scribbler.instance_variable_set "@config", nil
      end

      it "calls log, skips templater and still works" do
        subject.send(:build_with_template,
                     :object => some_object,
                     :template => false,
                     :message => "test\n123").should == "test\n123"
      end

      it "calls log and gets message with template wrapper" do
        subject.send(:build_with_template,
                     :template => true,
                     :object => some_object,
                     :message => <<-MSG
        test
        123
        MSG
                    ).should == <<-MSG.strip_heredoc
        -------------------------------------------------
        now
        SomeObject: no id
        test
        123

                    MSG
      end

      it "calls log and gets message with custom params" do
        subject.send(:build_with_template,
                     :template => true,
                     :object => some_object,
                     :custom_fields => {:test1 => 1, :test2 => 2},
                     :message => <<-MSG
        test
        123
        MSG
                    ).should == <<-MSG.strip_heredoc
        -------------------------------------------------
        now
        SomeObject: no id
        Test1: 1
        Test2: 2
        test
        123

                    MSG
      end
    end
  end
end
