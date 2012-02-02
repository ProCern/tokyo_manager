require 'tokyo_tyrant'

require 'tokyo_manager/shell'
require 'tokyo_manager/helpers'
require 'tokyo_manager/connection_manager'
require 'tokyo_manager/instance_manager'

require 'tokyo_manager/railtie' if defined?(Rails) && Rails.version =~ /^3/

module TokyoManager
  class Configuration
    attr_accessor :host, :default_port

    def initialize
      @host = 'localhost'
      @default_port = 1978
    end
  end

  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
