module Scribbler
  class BaseIncluder # I don't love this
    # Wonky way of allowing Base to include the Includeables.
    # Receives require errors with this currently.
    #
    # Examples:
    #
    #   BaseIncluder.include_includeables
    #   # => Nothing
    #
    # Returns Nothing
    # TODO Rework; there must be a more sane way of including these
    def self.include_includeables
      Scribbler::Base.send :include, Scribbler::Includeables
    end
  end

  module Includeables
    extend ActiveSupport::Concern

    included do
      build_methods
    end

    module ClassMethods
      def build_methods
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
        Scribbler::Base.config.logs.each do |value|
          define_singleton_method "#{value}_log_location" do
            Rails.root.join('log', "#{value}.log")
            #TODO remove dependence on Rails here
          end
        end
      end

      # Public: Save ourselves some repetition. Notifies error to NewRelic
      # and drops given string into a given log.
      #
      # location  - Either a pathname from the above method or symbol for an above
      #             method
      # options   - Hash of options for logging on Ngin
      #           :error     - Error object, mostly for passing to NewRelic
      #           :message   - Message to log in the actual file
      #           :new_relic - Notify NewRelic of the error (default: true)
      #
      # Examples
      #
      #   log(Ngin.subseason_log_location, :error => e, :message  => "Error message stuff", :new_relic => false)
      #
      #   log(:subseason, :error => e, :message => "Error message stuff")
      #
      #   log(:subseason, :message => "Logging like a bauss")
      #
      # Returns Nothing.
      def log(location, options={})
        begin
          NewRelic::Agent.notice_error(options[:error]) if options[:error] and options[:new_relic] != false
        rescue NameError
          nil
        end

        real_location = location
        if real_location.is_a?(Symbol) or real_location.is_a?(String)
          real_method = location.to_s + "_log_location"
          real_location = self.send(real_method) if self.respond_to? real_method
          real_location = real_location.to_s
        end

        #if File.exists?(real_location) and options[:message].present?
        if options[:message].present?
          log = File.open(real_location, 'a')
          log.puts options[:message]
          log.close
        end
      end
    end
  end
end
