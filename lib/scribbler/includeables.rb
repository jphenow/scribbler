module Scribbler
  module Includeables
    extend ActiveSupport::Concern
    included do
      delegate :log_location_regex,
        :log_at,
        to: :magic

      delegate :log,
        to: :logger
    end

    module ClassMethods
      def magic
        MagicLocation.new
      end

      def logger
        Logger.new
      end

      # Public: defines methods for log location. The first element
      # defines the prefix for the method so "subseason" = subseason_log_location.
      # The second element defines the name of the logfile so "subseason" =
      # root_of_app/log/subseason.log
      #
      # Examples
      #
      #   subseason_log_location
      #   # => #<Pathname:/path_to_ngin/log/subseason_copy_structure.log>
      #
      # Returns Pathname to log
      def method_missing(name, *args, &block)
        (match = name.to_s.match log_location_regex) ? log_at(match[:file]) : super
      end

      def respond_to?(name)
        (m = name.to_s.match log_location_regex) ? !!m : super
      end
    end
  end
end
