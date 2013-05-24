require 'spec_helper'

module Scribbler
  describe Base do
    subject { described_class }

    describe "configure" do
      it "sets some config variables" do
        subject.configure do
          config.application_include = true
        end
        subject.config.application_include.should be_true
      end
    end
  end
end
