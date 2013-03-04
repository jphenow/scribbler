module Scribbler::Base
  def self.method_missing(method, *args, &block)
    if Scribbler.respond_to? method
      puts "DEPRECATION WARNING: Scribbler is now preferred over Scribbler::Base see github for more info"
      Scribbler.public_send method, *args, &block
    else
      super
    end
  end

  def self.respond_to?(method, include_private = false)
    Scribbler.respond_to?(method) || super
  end
end
