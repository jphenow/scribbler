require 'spec_helper'

module Scribbler
  describe Executable do
    let(:cli) { double }
    before do
      subject.stub cli: cli
    end
    describe '.install' do
      it 'runs some CLI commands' do
        cli.should_receive(:run_command).with("mkdir -p #{Base.default_install_path}")
        cli.should_receive(:mass_copy).with(Base.templates, Base.default_install_path)
        subject.install
      end

      let(:custom_path) { '/some/custom/path' }
      it 'runs changes install path with given option' do
        cli.should_receive(:run_command).with("mkdir -p #{custom_path}")
        cli.should_receive(:mass_copy).with(Base.templates, custom_path)
        subject.install :path => custom_path
      end
    end
  end
end
