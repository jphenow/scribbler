module Scribbler
  class CLIClient
    # Run a shell command and output clean text explaining what happened
    #
    # command   - Shell command to run
    # poptions   - Set of options to alter default behavior
    #           :output - Disable default out of the command (default: true)
    #
    # Examples:
    #
    #   CLI.run_command('pwd')
    #   # No output, because no pwd association yet
    #   # => '/some/dir'
    #
    #   CLI.run_command('cp x y')
    #   # Copying files
    #   # => nothing
    #
    #   CLI.run_command('cp x y', :output => false)
    #   # => nothing
    #
    # Returns the backtick return of the command
    def run_command(command, poptions={})
      options = {:output => true}.merge(poptions)
      output command if options[:output]
      `#{command}`
    end

    # Copy a list of files to one location with one output
    # for the whole copy
    #
    # files       - List of strings representing files to be copied
    # destination - Directory to send the files
    #
    # Examples:
    #
    #   CLI.mass_copy(['/etc/a.file', 'etc/b.file'], '/tmp')
    #   # "Copying files"
    #   # => Nothing
    #
    # Returns Nothing
    def mass_copy(files, destination)
      output 'cp'
      files.each do |file|
        run_command "cp #{file} #{destination}", :output => false
      end
    end

    private

    # Central method for outputting text. Will serve
    # as a central location for changing how Scribbler outputs
    #
    # text  - Text to output
    #
    # Examples:
    #
    #   CLI.say "Output stuff"
    #   # "Output stuff"
    #   # => "Output stuff"
    #
    # Returns whatever `puts` command returns
    def say(text)
      puts text
    end

    # Get the command and try to output a human description
    # of what's happening
    #
    # command   - Whole command that we're finding output for
    #
    # Examples:
    #
    #   CLI.output 'cp x y'
    #   # "Copying files"
    #   # => "Copying files"
    #
    #   CLI.output 'mkdir /a/dir'
    #   # "Checking necessary directories are in place"
    #   # => "Checking necessary directories are in place"
    #
    # Returns Nothing
    def output(command)
      base_command = command.split(' ').first
      say out_definitions[base_command]
    end

    def out_definitions
      Hash.new { |h,k| h[k.to_s] ||= "Running command: #{k}" }.tap { |hash|
        hash["cp"] = "Coping files"
        hash["mkdir"] = "Checking necessary directories are in place"
      }
    end
  end
end
