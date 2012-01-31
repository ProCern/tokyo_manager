require 'tokyo_tyrant'

require 'tokyo_manager/version'
require 'tokyo_manager/configuration'
require 'tokyo_manager/helpers'
require 'tokyo_manager/connection_manager'
require 'tokyo_manager/instance_manager'

module TokyoManager
  include :Version
  include :Configuration
  include :Helpers
  include :ConnectionManager
  include :InstanceManager
end
