require 'spec_helper'

module ::Rails; end
module ::NewRelic
  module Agent; end
end
module Scribbler
  describe Logger do
    describe "class" do
      subject { Logger }

      it { should respond_to :log }

      it "instantiates and uses instance #log" do
        Logger.any_instance.should_receive(:log).once
        subject.log(:location)
      end
    end

    describe "instance" do
      subject { Logger.new location, options }
      let(:location) { nil }
      let(:options) { {} }
      let(:file) { double puts: true }
      before do
        Time.stub :now => "now"
        File.stub(:open).and_yield(file)
      end

      describe "instantiation" do
        its(:location) { should be_nil }
        its(:options) { should == { template: false, stack_frame: nil } }
      end

      describe "log" do
        let(:options) { { message: "fail", error: "Lots of fails", new_relic: true } }
        before do
          subject.should_receive(:apply_to_log).once
        end

        describe "with newrelic" do
          before do
            ::NewRelic::Agent.should_receive(:notice_error).with(options[:error]).once
          end

          its(:log) { should be_nil }
        end

        describe "without newrelic" do
          before do
            ::NewRelic::Agent.stub(:notice_error) do
              raise NameError
            end
          end

          its(:log) { should be_nil }
        end

        describe "newrelic set to off" do
          let(:options) { { message: "fail", error: "Lots of fails", new_relic: false } }
          before do
            ::NewRelic::Agent.should_not_receive(:notice_error)
          end
        end

        describe "no error, new relic on" do
          let(:options) { { message: "fail", new_relic: true } }
          before do
            ::NewRelic::Agent.should_not_receive(:notice_error)
          end
        end
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

        describe "nil file" do
          let(:file) { double puts: nil }
          it "should not work without location" do
            subject.send(:apply_to_log).should be_nil
          end
        end

        describe "no message" do
          let(:file) { double puts: nil }
          it "should not work without message" do
            subject.should_not_receive :test_log_log_location
            subject.stub location: :test_log
            subject.send(:apply_to_log).should be_nil
          end
        end

        it "should build a template and try to put it in a file" do
          subject.stub location: :test_log, options: { message: "..." }
          subject.send :apply_to_log
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
          subject.stub options: {
            object: some_object,
            template: false,
            message: "test\n123"
          }

          subject.send(:build_with_template).should == "test\n123"
        end

        it "calls log and gets message with template wrapper" do
          subject.stub options: {
            template: true,
            object: some_object,
            message: <<-MSG
        test
        123
            MSG
          }
          subject.send(:build_with_template).should == <<-MSG.strip_heredoc
        -------------------------------------------------
        now
        SomeObject: no id
        test
        123

          MSG
        end

        it "calls log and gets message with custom params" do
          subject.stub options: {
            template: true,
            object: some_object,
            custom_fields: { test1: 1, test2: 2 },
            message: <<-MSG
        test
        123
            MSG
          }
          subject.send(:build_with_template).should == <<-MSG.strip_heredoc
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
end
