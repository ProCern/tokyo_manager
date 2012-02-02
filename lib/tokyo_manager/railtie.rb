require 'rails'

module TokyoManager
  class Railtie < Rails::Railtie
    initializer 'tokyo_manager.configure' do |app|
      TokyoManager.configure do |config|
        database_configuration = Rails.configuration.database_configuration["observations_#{Rails.env}"]
        config.host = database_configuration['host'] || 'localhost'
        config.default_port = Integer(database_configuration['port'] || 1978)
      end
    end
  end
end
