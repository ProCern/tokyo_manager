require 'tokyo_manager/linux_instance_management'
require 'tokyo_manager/darwin_instance_management'

module TokyoManager
  # Starts a new master instance of TokyoTyrant for a date using the
  # InstanceManager.
  #
  # Example usage:
  #
  #     TokyoManager.start_master_for_date(Date.new(2012, 2, 1))
  def self.start_master_for_date(date, options = {})
    InstanceManager.new.start_master_for_date(date, options)
  end

  # Starts a new slave instance of TokyoTyrant for a date using the
  # InstanceManager.
  #
  # Example usage:
  #
  #     TokyoManager.start_slave_for_date(Date.new(2012, 2, 1), 'tt.ssbe.api')
  def self.start_slave_for_date(date, master_host, options = {})
    InstanceManager.new.start_slave_for_date(date, master_host, options)
  end

  # Deletes a master instance of TokyoTyrant for a date using the
  # InstanceManager.
  #
  # Example usage:
  #
  #     TokyoManager.delete_master_for_date(Date.new(2012, 2, 1))
  def self.delete_master_for_date(date)
    InstanceManager.new.delete_master_for_date(date)
  end

  # Deletes a slave instance of TokyoTyrant for a date using the
  # InstanceManager.
  #
  # Example usage:
  #
  #     TokyoManager.delete_slave_for_date(Date.new(2012, 2, 1))
  def self.delete_slave_for_date(date)
    InstanceManager.new.delete_slave_for_date(date)
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
    def start_master_for_date(date, options = {})
      port = master_port_for_date(date)

      if server_running_on_port?(port)
        raise "Server is already running for #{date.strftime('%m/%Y')} on port #{port}"
      end

      create_master_launch_script(port, date, options)
      start_server(:master, date)
      reduce_old_master_server_memory(date, options) if respond_to?(:reduce_old_master_server_memory)
    end

    # Starts a slave instance of TokyoTyrant to store data for the month of a
    # given date. If the server is already running, an error is raised.
    # Otherwise, a launch script is created and the new server is started. If
    # supported, the instance used to store data 2 months prior to the given
    # date is reconfigured to use less memory and restarted.
    def start_slave_for_date(date, master_host, options = {})
      master_port = master_port_for_date(date)
      slave_port = slave_port_for_date(date)

      if server_running_on_port?(slave_port)
        raise "Server is already running for #{date.strftime('%m/%Y')} on port #{slave_port}"
      end

      create_slave_launch_script(master_host, master_port, slave_port, date, options)
      start_server(:slave, date)
      reduce_old_slave_server_memory(master_host, date, options) if respond_to?(:reduce_old_slave_server_memory)
    end

    # Deletes a master instance of TokyoTyrant for the month of a given date
    # including all of its data. If the server is not running, an error is raised.
    def delete_master_for_date(date)
      port = master_port_for_date(date)

      unless server_running_on_port?(port)
        raise "Server is not running for #{date.strftime('%m/%Y')} on port #{port}"
      end

      stop_server(:master, date)
      delete_master_launch_script(date)
      delete_master_data(date)
    end

    # Deletes a slave instance of TokyoTyrant for the month of a given date
    # including all of its data. If the server is not running, an error is raised.
    def delete_slave_for_date(date)
      port = slave_port_for_date(date)

      unless server_running_on_port?(port)
        raise "Server is not running for #{date.strftime('%m/%Y')} on port #{port}"
      end

      stop_server(:slave, date)
      delete_slave_launch_script(date)
      delete_slave_data(date)
    end

    private

    # Determines if a server is already running on a given port.
    def server_running_on_port?(port)
      Shell.execute('ps aux | grep ttserver').chomp.split("\n").any? { |line| line =~ /-port #{port}/ }
    end
  end
end
