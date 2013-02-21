module Scribbler
  class Logger
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
    def log(location, options = {})
      options = {
        :template => config.use_template_by_default,
        :stack_frame => options[:call_stack] ? Kernel.caller[1..-1] : nil
      }.merge options
      begin
        NewRelic::Agent.notice_error(options[:error]) if options[:error] and options[:new_relic] != false
      rescue NameError
        nil
      end

      apply_to_log location, options
    end

    def log_at(file_name)
      LogLocation.new.find_path file_name
    end

    private

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
    def build_with_template(options={})
      if options[:message].present?
        options[:message] = options[:message].strip_heredoc.rstrip
        options[:template] ? config.template.call(options) : options[:message]
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
    #   Base.apply_to_log :some_loc, :message => "...", :template => false, :error => e
    #   # => Nothing
    #
    # Returns Nothing
    def apply_to_log(location, options={})
      if can_apply_to_log? location, options
        File.open log_at(location), 'a' do |f|
          f.puts build_with_template(options)
        end
      end
    end

    # TODO: Fix to work with any template
    def can_apply_to_log?(location, options)
      location.present? and
        (options[:message].present? or
         options[:object].present? or
         options[:custom_fields].present?)
    end
  end
end
