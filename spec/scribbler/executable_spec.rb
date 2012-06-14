require 'spec_helper'

module Scribbler
  describe Executable do
    subject { Executable }
    describe '.install' do
      it 'runs some CLI commands' do
        CLI.should_receive(:run_command).with("mkdir -p #{Base.default_install_path}")
        CLI.should_receive(:mass_copy).with(Base.templates, Base.default_install_path)
        subject.install
      end

      let(:custom_path) { '/some/custom/path' }
      it 'runs changes install path with given option' do
        CLI.should_receive(:run_command).with("mkdir -p #{custom_path}")
        CLI.should_receive(:mass_copy).with(Base.templates, custom_path)
        subject.install :path => custom_path
      end
    end
  end
end
