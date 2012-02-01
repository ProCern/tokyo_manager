require 'tokyo_manager/linux_instance_management'
require 'tokyo_manager/darwin_instance_management'

module TokyoManager
  # Starts a new master instance of TokyoTyrant for a date using the
  # InstanceManager.
  #
  # Example usage:
  #
  #     TokyoManager.start_master_for_date(Date.new(2012, 2, 1))
  def self.start_master_for_date(date)
    InstanceManager.new.start_master_for_date(date)
  end

  # Starts a new slave instance of TokyoTyrant for a date using the
  # InstanceManager.
  #
  # Example usage:
  #
  #     TokyoManager.start_slave_for_date(Date.new(2012, 2, 1))
  def self.start_slave_for_date(date)
    InstanceManager.new.start_slave_for_date(date)
  end

  # Provides methods for managing instances of TokyoTyrant.
  class InstanceManager
    include TokyoManager::Helpers

    # Includes the correct module for managing instances of TokyoTyrant
    # depending on the platform we are running on.
    def initialize
      if linux?
        extend TokyoManager::LinuxInstanceManagement
      else
        extend TokyoManager::DarwinInstanceManagement
      end
    end

    # Starts a master instance of TokyoTyrant to store data for the month of a
    # given date. If the server is already running, an error is raised.
    # Otherwise, a launch script is created and the new server is started. If
    # supported, the instance used to store data 2 months prior to the given
    # date is reconfigured to use less memory and restarted.
    def start_master_for_date(date)
      port = master_port_for_date(date)

      if server_running_on_port?(port)
        raise "Server is already running for #{date.strftime('%m/%Y')} on port #{port}"
      end

      create_master_launch_script(port, date)
      start_server(:master, date)
      reduce_old_master_server_memory(date) if respond_to?(:reduce_old_master_server_memory)
    end

    # Starts a slave instance of TokyoTyrant to store data for the month of a
    # given date. If the server is already running, an error is raised.
    # Otherwise, a launch script is created and the new server is started. If
    # supported, the instance used to store data 2 months prior to the given
    # date is reconfigured to use less memory and restarted.
    def start_slave_for_date(date)
      master_port = master_port_for_date(date)
      slave_port = slave_port_for_date(date)

      if server_running_on_port?(slave_port)
        raise "Server is already running for #{date.strftime('%m/%Y')} on port #{slave_port}"
      end

      create_slave_launch_script(master_port, slave_port, date)
      start_server(:slave, date)
      reduce_old_slave_server_memory(date) if respond_to?(:reduce_old_slave_server_memory)
    end

    private

    # Determines if a server is already running on a given port.
    def server_running_on_port?(port)
      Shell.execute('ps aux | grep ttserver').chomp.split("\n").any? { |line| line =~ /-port #{port}/ }
    end
  end
end
