module TokyoManager
  module Configuration
    def host
      if rails_configuration
        rails_configuration['host']
      else
        'localhost'
      end
    end

    def default_port
      if rails_configuration
        Integer(rails_configuration['port']) || 1978
      else
        1978
      end
    end

    private

    def rails_configuration
      if defined? Rails
        Rails.configuration.database_configuration["observations_#{Rails.env}"]
      end
    end
  end
end
