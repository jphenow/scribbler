require 'spec_helper'
module Scribbler
  describe LogLocation do
    its(:config) { should be_a Configurator }

    it "builds a basic path" do
      relative_path = subject.find_path(:subseason).to_s.split("/")[-3..-1].join("/")
      relative_path.should == "scribbler/log/subseason.log"
    end
  end
end
