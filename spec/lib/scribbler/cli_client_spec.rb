require 'spec_helper'

module Scribbler
  describe CLIClient do
    let(:cp_command) { 'cp x y' }
    describe '.run_command' do
      it 'calls backtick command with output' do
        subject.should_receive(:`).with(cp_command)
        subject.should_receive(:output).with(cp_command)
        subject.run_command cp_command
      end

      it 'calls backtick command without output' do
        subject.should_receive(:`).with(cp_command)
        subject.should_not_receive(:output)
        subject.run_command cp_command, :output => false
      end
    end

    describe '.say' do
      it 'calls puts wth the param' do
        subject.should_receive(:puts).with("Boom")
        subject.send :say, "Boom"
      end
    end

    describe '.mass_copy' do
      let(:file_list) { ["/tmp/fake_file_1", "/tmp/fake_file 2"] }
      let(:destination) { "/tmp/destination" }
      let(:out_definitions) { subject.send :out_definitions }
      it "copies all the files to the destination" do
        subject.should_receive(:say).with(out_definitions['cp']).once
        subject.should_receive(:run_command).with("cp #{file_list[0]} #{destination}", :output => false).once
        subject.should_receive(:run_command).with("cp #{file_list[1]} #{destination}", :output => false).once
        subject.mass_copy file_list, destination
      end
    end
  end
end
