module Scribbler
  class Configurator
    class << self
      attr_accessor :yaml_config_path, :yaml_config, :logs, :application_include
    end

    def self.yaml_config
      (@yaml_config ||= YAML::load(File.open(Configurator.yaml_config_path)) || {}).with_indifferent_access
    end

    def self.logs
      (@logs ||= (Configurator.yaml_config[:logs] || {})).with_indifferent_access
    end

    def self.application_include
      (@application_include ||= (Configurator.yaml_config[:application_include] || false)).with_indifferent_acces
    end

    def self.yaml_config_path
      begin
        @yaml_config_path || Rails.root.join('config', 'scribbler.yml')
      rescue NameError
        nil
      end
    end
  end
end
