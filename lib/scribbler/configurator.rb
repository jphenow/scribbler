module Scribbler
  class Configurator
    class << self
      attr_accessor :logs, :application_include
    end

    def self.logs
      @logs ||= []
    end

    def self.application_include
      @application_include || false
    end
  end
end
