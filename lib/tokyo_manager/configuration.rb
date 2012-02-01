module TokyoManager
  module Configuration
    # Gets the host from the Rails configuration file if used in a Rails
    # project. Otherwise, defaults to localhost.
    def host
      if rails_configuration
        rails_configuration['host']
      else
        'localhost'
      end
    end

    # Gets the default port to use when an instance is not running on the port
    # for a date. Uses the port from the Rails configuration file if used in a
    # Rails project. Otherwise, defaults to 1978 which is the default port for
    # TokyoTyrant and is where the database used before the TokyoManager was
    # used is running.
    def default_port
      (rails_configuration && rails_configuration['port']) ? Integer(rails_configuration['port']) : 1978
    end

    private

    # Gets the Rails configuration settings for the observation database if
    # used in a Rails project.
    def rails_configuration
      if defined? Rails
        Rails.configuration.database_configuration["observations_#{Rails.env}"]
      end
    end
  end
end
