# Scribbler

Scribbler is a little utility for simplifying logging across one application or more.
Currently it assists in:

* Dynamically defining methods for accessing the log files
* Centralized log method for file, message, and error checks
  - Currently also able to notify NewRelic, abstraction and extension to come

## Usage

In your Rails project add

    gem scribbler

to your Gemfile and

    bundle install

Then

    rake scribbler:install

You'll find your configuration options in `config/initializers/scribbler.rb`.
As an example, with this configuration file in a Rails app called `Blogger`:

    Scribbler::Base.configure do
      config.application_include = true
      config.logs %w[production delayed_job]
    end

You are given a few methods for free. To get the production logfile location:

    Blogger.production_log_location
    # => <#Path: Rails.root.join('log', 'production.log')>

or

    Scribbler::Base.production_log_location
    # => <#Path: Rails.root.join('log', 'production.log')>

More importantly you're given access to a sweet `log` method:

    # Notifies NewRelic and drops the message in log found at Blogger.production_log_location
    Blogger.log :production, :error => e, :message => "#{e} broke stuff"
    Scribbler::Base.log :production, :error => e, :message => "#{e} broke stuff"

    # Only logs to log/delayed_job.log and doesn't notify NewRelic
    Blogger.log :delayed_job, :message => "Successfully executed Delayed Job"
    Scribbler::Base.log :delayed_job, :message => "Successfully executed Delayed Job"

    # Doesn't notify NewRelic but gives the method access to the error and logs the message
    # to the given logfile
    Blogger.log 'production', :new_relic => false, :error => e, :message => "#{e} broke stuff"
    Scribbler::Base.log 'production', :new_relic => false, :error => e, :message => "#{e} broke stuff"

    # Logs to given file without using the fancy log methods
    Blogger.log File.expand_path(File.join(File.dirname(__FILE__), 'logfile.log')), :message => "#{e} broke stuff"
    Scribbler::Base.log File.expand_path(File.join(File.dirname(__FILE__), 'logfile.log')), :message => "#{e} broke stuff"

## Todo

* Finish making `rake scribbler:install` copy some initial template files
* More options in configure
* More testing
* Make block available in log method for better extensibility
* Currently attempts to notify NewRelic if its there, abstract and allow custom services
