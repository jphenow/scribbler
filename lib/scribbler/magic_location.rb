module Scribbler
  class MagicLocation
    def log_location_regex
      /(?<file>.*)_log_location$/
    end

    def log_at(file_name)
      File.join config.log_directory, "#{file_name}.log"
    end

    def config
      Scribbler.config
    end
  end
end
