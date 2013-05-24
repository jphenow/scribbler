module Scribbler
  module Base
    def self.configure(&block)
      ActiveSupport::Deprecation.deprecated_method_warning :configure,
        "Scribbler is now preferred over Scribbler::Base see github for more info"
      Scribbler.configure { |config| config.instance_eval(&block) }
    end

    def self.method_missing(method, *args, &block)
      if Scribbler.respond_to? method
        ActiveSupport::Deprecation.deprecated_method_warning method,
          "Scribbler is now preferred over Scribbler::Base see github for more info"
        Scribbler.public_send method, *args, &block
      else
        super
      end
    end

    def self.respond_to?(method, include_private = false)
      Scribbler.respond_to?(method) || super
    end
  end
end
