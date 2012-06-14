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

      #TODO
      it 'runs changes install path with given option' do
        #subject.install
      end
    end
  end
end
