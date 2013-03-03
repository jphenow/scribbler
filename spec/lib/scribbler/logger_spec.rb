require 'spec_helper'

module ::Rails; end
module Scribbler
  describe Logger do
    subject { Logger.new location, options }
    let(:location) { nil }
    let(:options) { {} }
    let(:file) { double puts: true }
    before do
      Time.stub :now => "now"
      File.stub(:open).and_yield(file)
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
