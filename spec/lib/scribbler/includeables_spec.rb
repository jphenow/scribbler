require 'spec_helper'
module Scribbler
  class IncludedTest
    include Includeables
  end

  describe IncludedTest do
    subject { IncludedTest }
    it { should respond_to :subseason_log_location }
    it { should respond_to :production_log_location }
    it { should respond_to :trees_log_location }

    its(:subseason_log_location) { should be_a Pathname }

    it "can call log_at manually" do
      subject.log_at(:subseason).should be_a Pathname
    end

    it "logs via Logger" do
      Logger.should_receive :log
      subject.log :location, {}
    end
  end
end
