# Scribbler

[![TravisCI](https://secure.travis-ci.org/jphenow/scribbler.png "TravisCI")](http://travis-ci.org/jphenow/scribbler "Travis-CI Scribbler")

[RubyGems](https://rubygems.org/gems/scribbler)

Scribbler is a little utility for simplifying logging across one application or more.
Currently it assists in:

* Dynamically defining methods for accessing the log files
* Centralized log method for file, message, and error checks
  - Currently also able to notify NewRelic, abstraction and extension to come

## Notes on upgrading to 0.3.0

Scribbler was initially written with a lot of class-level (almost entirely) operations.
For sanity sake, the version 0.3.0 is the big step towards dropping most of the gem into
instances. There isn't much functionality change yet, but it will make expanding the gem much
simpler to develop.

### Changes For You

`Scribbler::Base` is now deprecated, look to remove. See `Scribbler`

`Scribbler.configure` now yields the configurator so you now want to change from:

```ruby
Scribbler::Base.configure do
  config.some_config_options
  # ...
end
```

to

```ruby
Scribbler.configure do |config|
  config.some_config_options
  # ...
end
```

## Usage

In your Rails project add

```ruby
gem 'scribbler'
```

to your Gemfile and

```bash
bundle install
```

Then

```bash
scribbler install # For options do `scribbler` first
```

You'll find your configuration options in `config/initializers/scribbler.rb`.
**Better, more documented examples in the template file provided by `scribbler install`**
As an example, with this configuration file in a Rails app called `Blogger`:

```ruby
Scribbler.configure do |config|
  config.application_include = true

  # config.log_directory = File.new '/a/better/path'

  config.use_template_by_default = true # Default: false

  # config.template = proc do |options|
  #   <<-MSG
  #   ##########
  #   Cool template bro!
  #   Message: #{options[:message]}
  #   MSG
  # end
end
```

You are given a few methods for free. To get the production logfile location:

```ruby
Blogger.production_log_location
# => <#Path: Rails.root.join('log', 'production.log')>
```

or

```ruby
Scribbler.production_log_location
# => <#Path: Rails.root.join('log', 'production.log')>
```

More importantly you're given access to a sweet `log` method:

```ruby
# Notifies NewRelic and drops the message in log found at Blogger.production_log_location
Blogger.log :production, :error => e, :message => "#{e} broke stuff"
Scribbler.log :production, :error => e, :message => "#{e} broke stuff"

# Only logs to log/delayed_job.log and doesn't notify NewRelic
Blogger.log :delayed_job, :message => "Successfully executed Delayed Job"
Scribbler.log :delayed_job, :message => "Successfully executed Delayed Job"

# Doesn't notify NewRelic but gives the method access to the error and logs the message
# to the given logfile
Blogger.log 'production', :new_relic => false, :error => e, :message => "#{e} broke stuff"
Scribbler.log 'production', :new_relic => false, :error => e, :message => "#{e} broke stuff"

# Logs to given file without using the fancy log methods
Blogger.log File.expand_path(File.join(File.dirname(__FILE__), 'logfile.log')), :message => "#{e} broke stuff"
Scribbler.log File.expand_path(File.join(File.dirname(__FILE__), 'logfile.log')), :message => "#{e} broke stuff"
```

Log options with the default template proc:

```
# options   - Hash of options for logging on Ngin
#             :error            - Error object, mostly for passing to NewRelic
#             :message          - Message to log in the actual file [REQUIRED]
#             :custom_fields    - Custom fields dropped into the default template
#             :template         - Whether or not to use the template at this log
#             :new_relic        - Notify NewRelic of the error (default: true)
```

With the template enabled (either during call to log [:template => true] or by setting to
be used by default) you will have each log entry wrapped into a template to pretty-up and
get some more boilerplate data. As you can see in the config above. See method
docs and specs for more information.

## Todo

* Configure the module/class receiving the include
* Configurable notification gem (NewRelic, Airbrake, etc.)
* Have default template cascade through hashes/arrays for prettier viewing
* Currently attempts to notify NewRelic if its there, abstract and allow custom services
* Allow a class to set default options for a log call within itself
* Allow there to be a log made without the option[:message], in case its all custom_fields or someting
* Allow event hooks on log call?
