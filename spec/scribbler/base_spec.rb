require 'spec_helper'

module Scribbler
  describe Base do
    subject { Base }

    before :each do
      Object.send :remove_const, :Rails if defined?(Rails) == 'constant' && Rails.class == Class
    end

    it "should give me a configurator" do
      subject.config.should == Scribbler::Configurator
    end

    describe "include_in_application" do
      it "should attempt to include to the Rails app" do
        module ::Rails; end
        ::Rails.stub(:application => stub(:class => stub(:parent => stub(:send => true))))
        subject.stub(:config => stub(:application_include => true))
        subject.include_in_application.should be_true
      end

      it "should return nil because it caught the NameError of Rails not existing" do
        subject.stub(:config => stub(:application_include => true))
        subject.include_in_application.should be_nil
      end

      it "should not attempt to include in app if config is false" do
        subject.stub(:config => stub(:application_include => false))
        subject.include_in_application.should be_nil
      end
    end

    describe "configure" do
      it "kicks off the module and sends includes" do
        subject.should_receive(:include_in_application).once
        BaseIncluder.should_receive(:include_includeables).once
        subject.configure do
        end
      end

      it "sets some config variables" do
        subject.configure do
          config.application_include = true
        end
        subject.config.application_include.should be_true
      end
    end
  end
end
