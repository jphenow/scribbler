module Scribbler
  class Configurator
    attr_accessor :logs, :application_include, :template, :use_template_by_default, :log_directory

    # Gets the path of this Gem
    #
    # Examples:
    #
    #   Base.gem_path
    #   # => '/some/home/.rvm/gems/ruby-1.9.3-p125/gems/scribbler-0.0.1/'
    #
    # Returns String of the current gem's directory path
    def gem_path
      File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
    end

    # Gets all the paths to the template files in the gem's template directory
    #
    # Examples:
    #
    #   Base.templates
    #   # => ['/some/home/.rvm/gems/ruby-1.9.3-p125/gems/scribbler-0.0.1/templates/1.rb',
    #   #     '/some/home/.rvm/gems/ruby-1.9.3-p125/gems/scribbler-0.0.1/templates/2.rb]
    #
    # Returns Array of Strings of the gem's template files
    def templates
      Dir.glob(File.join(gem_path, 'templates', '*'))
    end

    # Gets the path to the default install directory. If Rails is present
    # it will default to the Rails.root/config/initializers/. Otherwise
    # it assumes its the $PWD/config/initializer. Should look at a cleaner
    # abstraction of this
    #
    # Examples:
    #
    #   Base.default_install_path
    #   # => '/some/home/projects/rails_app/config/initializers/'
    #
    # Returns String for best guess of a good install path
    def default_install_path
      begin
        ::Rails.root.join 'config', 'initializers', ''
      rescue NameError
        File.join Dir.pwd, 'config', 'initializers', ''
      end
    end

    # Provides location for getting the directory Scribbler will place
    # log files in. Favors RailsApplication/log/ but falls back to
    # $PWD/log if not set in config
    #
    # Examples
    #
    #   Configurator.log_directory
    #   # => "/some/path/to/log/"
    #
    # Returns String for log directory location
    def log_directory
      @log_directory ||= begin
                           Rails.root.join('log')
                         rescue NameError
                           File.join Dir.pwd, 'log'
                         end
    end


    # Boolean used for deciding whether or not Scribbler should
    # define #*_log_location methods and a .log method in a rails application
    #
    # Default: false
    #
    # Examples
    #
    # Scribbler::Configurator.application_include
    # # => false
    #
    # Returns boolean
    #
    # TODO: Allow the class we're sending the include to to be custom
    def application_include
      @application_include || false
    end

    # Boolean for deciding if we should use the logger template by
    # by default when calling Base.log
    #
    # Default: false
    #
    # Examples
    #
    # Scribbler::Configurator.use_template_by_default
    # # => false
    #
    # Returns boolean
    def use_template_by_default
      @use_template_by_default || false
    end

    # The method that sets a template for each log made with
    # Base.log
    #
    # The template proc is given the whole options hash that is
    # passed through Base.log or YourApplication.log. So if you
    # had:
    #
    #   YourApplication.log :a_log,
    #                       :message => "information data",
    #                       :custom => "stuff"
    #
    # Then you can assume the template proc will get:
    #
    # options = {
    #   :message => "information data",
    #   :custom => "stuff"
    # }
    #
    # To set a custom template:
    #
    #   Scribbler::Configurator.template = proc do |options|
    #     "Message: options[:message]"
    #   end
    #
    # From Scribbler::Base.configure that would be:
    #
    #   config.template = proc do |options|
    #     "Message: options[:message]"
    #   end
    #
    # **Keep in mind** that the template can be ignored at any
    # Base.log call with:
    #
    #   Base.log :your_log, :template => false, :message "..."
    #
    # Default:
    #
    # -------------------------------------------------
    # SomeObject: #{id}                                 # options[:object] and options[:object].try(:id)
    # Custom1: some good info                           # options[:custom_fields] hash
    # Custom2: some better info                         # Left of colon is the key.humanize, right is the value
    # OH NO YOU BROKED STUFF                            # options[:message].strip_heredoc
    # DO PLX FIX                                        #
    #
    # Examples
    #
    #   Scribbler::Configurator.template
    #   # => <#Proc:...>
    #
    # Returns the proc that wraps around each log entry
    #
    # TODO: Block input that would break this
    # TODO: Test
    def template
      @template ||= proc do |options|
        begin
          if_id = options[:object].present? ? options[:object].try(:id) : 'no id'
        rescue NoMethodError, RuntimeError # Uber careful
          if_id = 'no id'
        end
        custom_fields = options[:custom_fields].to_a.collect { |x| "#{x[0].to_s.humanize}: #{x[1]}" }.join("\n")

        template = "-------------------------------------------------\n"
        template << "#{Time.now}\n"
        template << "#{options[:object].class.name}: #{if_id}\n" if options[:object]
        template << "#{custom_fields}\n" if custom_fields.present?
        template << "#{options[:message]}\n"
        template << "Call Stack:\n#{options[:stack_frame].join("\n")}\n" if options[:call_stack]
        template << "\n"
      end
    end
  end
end
