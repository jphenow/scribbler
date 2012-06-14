module Scribbler
  class Executable
    # Runs installer, makes dirs and copy's template files
    #
    # options   - Options from command in shell
    #           :path - changes the path its installing config files too
    #
    # TODO accept options[:path] for changing the install path
    def self.install(options={})
      CLI.run_command "mkdir -p #{Base.default_install_path}"
      CLI.mass_copy Base.templates, Base.default_install_path
    end
  end
end
