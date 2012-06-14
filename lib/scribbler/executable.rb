module Scribbler
  class Executable
    # Runs installer, makes dirs and copy's template files
    #
    # options   - Options from command in shell
    #           :path - changes the path its installing config files too
    #
    def self.install(options={})
      install_path = options[:path] || Base.default_install_path
      CLI.run_command "mkdir -p #{install_path}"
      CLI.mass_copy Base.templates, install_path
    end
  end
end
