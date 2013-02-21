module Scribbler
  class Executable
    # Runs installer, makes dirs and copy's template files
    #
    # options   - Options from command in shell
    #           :path - changes the path its installing config files too
    #
    def install(options={})
      install_path = options[:path] || Base.default_install_path
      cli.run_command "mkdir -p #{install_path}"
      cli.mass_copy Base.templates, install_path
    end

    def cli
      CLIClient.new
    end
  end
end
