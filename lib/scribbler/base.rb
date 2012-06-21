module Scribbler
  class Base
    # Gets the path of this Gem
    #
    # Examples:
    #
    #   Base.gem_path
    #   # => '/some/home/.rvm/gems/ruby-1.9.3-p125/gems/scribbler-0.0.1/'
    #
    # Returns String of the current gem's directory path
    def self.gem_path
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
    def self.templates
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
    def self.default_install_path
      begin
        ::Rails.root.join 'config', 'initializers', ''
      rescue NameError
        File.join Dir.pwd, 'config', 'initializers', ''
      end
    end

    # Rails style configure block with some cleanup afterwards. This is the
    # main method that kicks off the module and is necessary for its operation
    #
    # &block  - Block is class_eval'd to give total access to the config file.
    #           Most importantly giving access to `config` object
    #
    # Examples:
    #
    #   Base.configure do
    #     config.logs = %w[log1 log2]
    #     config.application_include = true
    #   end
    #   # => Nothing
    #
    # Returns Nothing
    # TODO Abstract the callbacks so that we can just add them where they're written
    def self.configure(&block)
      class_eval(&block)
      Base.include_in_application
      BaseIncluder.include_includeables
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
      Scribbler::Configurator
    end

    # Public: Save ourselves some repetition. Notifies error to NewRelic
    # and drops given string into a given log.
    #
    # location  - Either a pathname from the above method or symbol for an above
    #             method
    # options   - Hash of options for logging on Ngin
    #           :error     - Error object, mostly for passing to NewRelic
    #           :message   - Message to log in the actual file
    #           :new_relic - Notify NewRelic of the error (default: true)
    #
    # Examples
    #
    #   log(Ngin.subseason_log_location, :error => e, :message  => "Error message stuff", :new_relic => false)
    #
    #   log(:subseason, :error => e, :message => "Error message stuff")
    #
    #   log(:subseason, :message => "Logging like a bauss")
    #
    # Returns Nothing.
    def self.log(location, options={})
      options = {
        :template => config.use_template_by_default
      }.merge options
      begin
        NewRelic::Agent.notice_error(options[:error]) if options[:error] and options[:new_relic] != false
      rescue NameError
        nil
      end

      apply_to_log find_file_at(location), options
    end

    private
    #TODO docs
    def self.build_with_template(options={})
      if options[:message].present?
        options[:message] = options[:message].strip_heredoc.rstrip
        config.template.call(options) if options[:template]
      end
    end

    #TODO docs
    #TODO tests
    def self.apply_to_log(location, options={})
      if options[:message].present?
        log = File.open(location, 'a')
        log.puts build_with_template(message)
        log.close
      end
    end

    #TODO docs
    #TODO test
    def self.find_file_at(location)
      real_location = location
      if real_location.is_a?(Symbol) or real_location.is_a?(String)
        real_method = location.to_s + "_log_location"
        real_location = self.send(real_method) if self.respond_to? real_method
        real_location = real_location.to_s
      end
      real_location
    end

    # If the config agrees, attempt to include our special methods
    # in the main application object.
    #
    # Example:
    #
    #   Base.include_in_application
    #   # => Nothing
    #
    # Returns Nothing
    # TODO Allow config to define where we send the include
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
end
