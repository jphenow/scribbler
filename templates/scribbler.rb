Scribbler::Base.configure do
  # This is like the Rails configure. This is actually a #class_eval.
  # Unless you'd like to experiment with breaking things and battling dragons,
  # please only use what we document here.
  #
  # Include the log methods to the rails application. So, if you have an
  # application called Blog you can do Blog.log(...), rather than
  # Scribbler.log(...). Default: false
  #
  # config.application_include = true
  #
  #
  # What directory should these logs be placed in? The default is
  # to try the Rails log directory and fallback to the $PWD/log path
  #
  # config.log_directory = File.new '/a/better/path'
  #
  #
  # A list of the logs you'd like location methods for. if the logs list
  # has:
  #
  #   ['log1']
  #
  # You are afforded a Base.log1_log_location method and you may do:
  #
  #   Base.log :log1, ....
  #
  # REQUIRED
  #
  # config.logs = %w[log1 log2]
  #
  # This option enables log templating. Each time you log a message you
  # can have it automatically wrapped in some sugar. The default is something
  # like:
  #
  # -------------------------------------------------
  # SomeObject: #{id}                                 # options[:object] and options[:object].try(:id)
  # Custom1: some good info                           # options[:custom_fields] hash
  # Custom2: some better info                         # Left of colon is the key.humanize, right is the value
  # OH NO YOU BROKED STUFF                            # options[:message].strip_heredoc
  # DO PLX FIX                                        #
  #
  # If you would rather this not be default you may set this to false. Keep
  # in mind, there is an option on the Base.log to enable or disable the
  # template on a per-call basis. (:template)
  #
  # config.use_template_by_default = true # Default: false
  #
  #
  # Don't like the default template above? Write your own proc here.
  # The proc is given the options hash that you give to Base.log so you're
  # given plenty of control over what information you have to work with.
  #
  # options   - Hash of options for logging on Ngin
  #           :error            - Error object, mostly for passing to NewRelic
  #           :message          - Message to log in the actual file [REQUIRED]
  #           :custom_fields    - Custom fields dropped into the default template
  #           :template         - Whether or not to use the template at this log
  #           :new_relic        - Notify NewRelic of the error (default: true)
  #
  # config.template = proc do |options|
  #   <<-MSG
  #   ##########
  #   Cool template bro!
  #   Message: #{options[:message]}
  #   MSG
  # end
end
