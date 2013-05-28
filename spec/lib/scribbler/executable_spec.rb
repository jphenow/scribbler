require 'spec_helper'

module Scribbler
  describe Executable do
    its(:cli) { should be_a CLIClient }
    describe "stubbed CLI Client" do
      let(:cli) { double }
      let(:config) { Scribbler.config }
      before do
        subject.stub cli: cli
      end
      describe '.install' do
        it 'runs some CLI commands' do
          cli.should_receive(:run_command).with("mkdir -p #{config.default_install_path}")
          cli.should_receive(:mass_copy).with(config.templates, config.default_install_path)
          subject.install
        end

        let(:custom_path) { '/some/custom/path' }
        it 'runs changes install path with given option' do
          cli.should_receive(:run_command).with("mkdir -p #{custom_path}")
          cli.should_receive(:mass_copy).with(config.templates, custom_path)
          subject.install :path => custom_path
        end
      end
    end
  end
end
