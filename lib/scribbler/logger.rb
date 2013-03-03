module Scribbler
  class Logger
    private
    attr_accessor :location
    attr_accessor :options

    public

    def self.log(location, options = {})
      new(location, options).log
    end

    def initialize(location, options = {})
      self.location = location
      self.options = gather_log_options options
    end

    # Public: Save ourselves some repetition. Notifies error to NewRelic
    # and drops given string into a given log.
    #
    # location  - Either a pathname from the above method or symbol for an above
    #             method
    # options   - Hash of options for logging on Ngin
    #           :error            - Error object, mostly for passing to NewRelic
    #           :message          - Message to log in the actual file
    #           :custom_fields    - Custom fields dropped into the default template
    #           :template         - Whether or not to use the template at this log
    #           :new_relic        - Notify NewRelic of the error (default: true)
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
    def log
      notify_new_relic options[:error], options[:new_relic]
      apply_to_log
    end

    private

    def actual_log_location
      LogLocation.new.find_path location
    end

    def notify_new_relic(error, new_relic)
      NewRelic::Agent.notice_error(error) if error and new_relic != false
    rescue NameError
      nil
    end

    def gather_log_options(given_options)
      {
        :template => config.use_template_by_default,
        :stack_frame => given_options[:call_stack] ? Kernel.caller[1..-1] : nil
      }.merge given_options
    end

    def config
      Scribbler.config
    end

    # Builds the message and any other options into a string
    # using the template defined in the configure
    #
    # options   - options hash that comprises most of the important log pieces
    #           :message  - The message we're wrapping into the templater [required]
    #           :template - Whether or not to use the template method
    #           **Other option information given in the .log docs
    #
    # Examples
    #
    #   Base.build_with_template(:message => "...", :template => false)
    #   # => "..."
    #
    #   Base.build_with_template
    #   # => nil
    #
    #   Base.build_with_template(:message => "...", :template => true)
    #   # => <<-EXAMPLE
    #     --------------------
    #     TEMPLATE STUFF
    #     ....
    #     EXAMPLE
    #
    # Returns nil, a string, or a string built with calling the Configurator.template method
    def build_with_template
      options[:message] = options[:message].to_s.strip_heredoc.rstrip
      template.call options
    end

    def template
      if options.key?(:template)
        if options[:template]
          options[:template].is_a?(Proc) ? options[:template] : config.template
        else
          ->(o) { o[:message] }
        end
      else
        config.template
      end
    end

    # Drops built message into the log with the given location
    #
    # location    - location either found with Base.*_log_location or by hoping a valid
    #               path string or Path object were passed
    # options     - options hash
    #             :message - Message to be built and put in log file [required]
    #             ** Other hash information given in Base.log
    #
    # Examples
    #
    #   apply_to_log  # WITH :some_loc, :message => "...", :template => false, :error => e
    #   # => Nothing
    #
    # Returns Nothing
    def apply_to_log
      if can_apply_to_log?
        File.open actual_log_location, 'a' do |f|
          f.puts build_with_template
        end
      end
    end

    # TODO: Fix to work with any template
    def can_apply_to_log?
      location.present? and
        (options[:message].present? or
         options[:object].present? or
         options[:custom_fields].present?)
    end
  end
end
