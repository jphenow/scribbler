module Scribbler
  # TODO not sure this'll work
  delegate :configure, :to => :Base
  delegate :log, :to => :Base
  class Base
    def self.configure(&block)
      class_eval(&block)
      Base.include_in_application
      BaseIncluder.include_includeables
    end

    # Returns the class for configuration. Trying to keep this
    # a singleton.
    def self.config
      Scribbler::Configurator
    end

    def self.include_in_application
      begin
        Rails.application.class.parent.send :include, Includeables
      rescue NameError
        nil
      end
    end
  end
end
