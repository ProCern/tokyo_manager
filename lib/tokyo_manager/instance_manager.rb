require 'tokyo_manager/linux_instance_management'
require 'tokyo_manager/darwin_instance_management'

module TokyoManager
  def self.start_master_for_date(date)
    InstanceManager.new.start_master_for_date(date)
  end

  def self.start_slave_for_date(date)
    InstanceManager.new.start_slave_for_date(date)
  end

  class InstanceManager
    include TokyoManager::Helpers

    def initialize
      if linux?
        extend TokyoManager::LinuxInstanceManagement
      else
        extend TokyoManager::DarwinInstanceManagement
      end
    end

    def start_master_for_date(date)
      port = master_port_for_date(date)

      if server_running_on_port?(port)
        raise "Server is already running for #{date.strftime('%m/%Y')} on port #{port}"
      end

      create_master_launch_script(port, date)
      start_server(:master, date)
      reduce_old_master_server_memory(date) if respond_to?(:reduce_old_master_server_memory)
    end

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

    def server_running_on_port?(port)
      `ps aux | grep ttserver`.chomp.split("\n").any? { |line| line =~ /-port #{port}/ }
    end
  end
end
