require 'spec_helper'

module Scribbler
  describe Configurator do
    subject { Configurator }
    describe "yaml_config" do
      it "should default to an empty set" do
        subject.stub(:yaml_config_path => nil)
        subject.yaml_config.should == {}
      end

      it "should load the yaml file" do
        subject.stub(:yaml_config_path => example_yaml)
        subject.yaml_config.length.should == 2
        subject.yaml_config[:logs].length.should == 4
      end

      it "should have indifferent access" do
        subject.yaml_config.should have_key(:logs)
        subject.yaml_config.should have_key('logs')
      end

      it "should let me set it" do
        subject.yaml_config = { :logs => 'new' }
        subject.yaml_config[:logs].should == 'new'
      end
    end

    describe "logs" do
      before :each do
        subject.logs = nil
        subject.yaml_config_path = example_yaml
        subject.yaml_config = nil
      end

      it "should have indifferent access" do
        subject.logs['subseason'].should == 'subseason_copy_structure'
        subject.logs[:subseason].should == 'subseason_copy_structure'
      end

      it "should let me set it" do
        new_logs = {:one => '1', :two => '2'}.with_indifferent_access
        subject.logs = new_logs
        subject.logs.should == new_logs
      end
    end

    describe "application_include" do
      before :each do
        subject.yaml_config = nil
        subject.stub(:yaml_config_path => example_yaml)
      end

      it "get default from yaml" do
        subject.application_include.should == true
      end

      it "should let me set it" do
        subject.application_include = false
        subject.application_include.should == false
      end
    end

    describe "yaml_config_path" do
      let (:path) { '/some/path/to/rails/config/scribbler.yml' }

      before :each do
        subject.yaml_config = nil
        subject.yaml_config_path = nil
        Object.send :remove_const, :Rails if defined?(Rails) == 'constant' && Rails.class == Class
      end

      it "should default attempt Rails path" do
        module ::Rails; end
        ::Rails.stub(:root => stub(:join => path))
        subject.yaml_config_path.should == path
      end

      it "should return nil without Rails" do
        subject.yaml_config_path.should be_nil
      end

      it "should let me set it" do
        new_path = '/new/path/to/yaml'
        subject.yaml_config_path = new_path
        subject.yaml_config_path.should == new_path
      end
    end
  end
end
