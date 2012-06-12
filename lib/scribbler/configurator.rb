module Scribbler
  class Configurator
    class << self
      attr_accessor :yaml_config_path, :yaml_config, :logs, :application_include
    end

    def self.yaml_config
      unless @yaml_config.present?
        if yaml_config_path.present? and File.exists?(yaml_config_path)
          @yaml_config = YAML::load(File.open(yaml_config_path))
        else
          @yaml_config = {}
        end
      end
      @yaml_config.with_indifferent_access
    end

    def self.logs
      (@logs ||= (yaml_config[:logs] || {})).with_indifferent_access
    end

    def self.application_include
      if @application_include.nil?
        @application_include = yaml_config[:application_include] || false
      end
      @application_include
    end

    def self.yaml_config_path
      begin
        @yaml_config_path || ::Rails.root.join('config', 'scribbler.yml')
      rescue NameError
        nil
      end
    end
  end
end
