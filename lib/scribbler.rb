require 'active_support/all'
require 'scribbler/version'
require 'scribbler/configurator'
require 'scribbler/log_location'
require 'scribbler/logger'
require 'scribbler/includeables'
require 'scribbler/cli_client'
require 'scribbler/executable'

module Scribbler
  include Includeables
  # Rails style configure block with some cleanup afterwards. This is the
  # main method that kicks off the module and is necessary for its operation
  #
  # &block  - Block is class_eval'd to give total access to the config file.
  #           Most importantly giving access to `config` object
  #
  # Examples:
  #
  #   Scribbler.configure do |config|
  #     config.logs = %w[log1 log2]
  #     config.application_include = true
  #   end
  #   # => Nothing
  #
  # Returns Nothing
  # TODO Abstract the callbacks so that we can just add them where they're written
  def self.configure
    yield config
    include_in_application
  end

  # Simply returns the configurator class.
  #
  # Examples:
  #
  #   Base.config
  #   # => Scribbler::Configurator
  #
  # Returns the singleton configurator
  def self.config
    @config ||= Configurator.new
  end

  private

  # If the config agrees, attempt to include our special methods
  # in the main application object.
  #
  # Example:
  #
  #   Base.include_in_application
  #   # => Nothing
  #
  # Returns Nothing
  #
  # TODO: Allow config to define where we send the include
  def self.include_in_application
    if config.application_include
      begin
        ::Rails.application.class.parent.send :include, Includeables
      rescue NameError
        nil
      end
    end
  end
end
