module Scribbler
  class Configurator
    class << self
      attr_accessor :logs, :application_include, :template, :use_template_by_default
    end

    def self.logs
      @logs ||= []
    end

    def self.application_include
      @application_include || false
    end

    def self.use_template_by_default
      @use_template_by_default ||= false
    end

    def self.template
      @template ||= proc do |options|
        begin
          if_id = options[:object].id
        rescue NoMethodError
          if_id = "no id"
        end
        custom_fields = options[:custom_fields].to_a.collect { |x| "#{x[0].to_s.humanize}: #{x[1]}" }.join("\n")

        template = "-------------------------------------------------\n"
        template << "#{Time.now}\n"
        template << "#{options[:object].class.name}: #{if_id}\n" if options[:object]
        template << "#{custom_fields}\n" if custom_fields.present?
        template << "#{options[:message]}\n\n"
      end
    end
  end
end
