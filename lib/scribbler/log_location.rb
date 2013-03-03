require 'pathname'
module Scribbler
  class LogLocation
    def find_path(file_name)
      Pathname.new File.join(config.log_directory, "#{file_name}.log")
    end

    private
    def config
      Scribbler.config
    end
  end
end
