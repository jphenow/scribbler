Scribbler.configure do |config|
  # This is like the Rails configure. This is actually a #class_eval.
  # Unless you'd like to experiment with breaking things and battling dragons,
  # please only use what we document here.
  #
  # Alter the path to the configuration yaml. If you alter those variables
  # from this config, those here will take precedence. Don't confuse yourself
  # by having thos options here and there.
  #
  # config.yaml_config_path = Rails.root.join('config', 'scribbler.yml')
  #
  # Include the log methods to the rails application. So, if you have an
  # application called Blog you can do Blog.log(...), rather than
  # Scribbler.log(...). Default: false
  #
  # config.application_include = true
end
