require 'active_support/core_ext'

module TokyoManager
  # Provides methods for managing instances of TokyoTyrant running on Linux.
  module LinuxInstanceManagement
    # Creates an upstart script for running a master instance of TokyoTyrant.
    def create_master_launch_script(port, date, options = {})
      options = extract_master_instance_options(options)
      arguments = default_master_server_arguments(port, date).merge(options)
      create_upstart_script(:master, date, arguments)
    end

    # Deletes an upstart script for a master instance of TokyoTyrant.
    def delete_master_launch_script(date)
      delete_upstart_script(:master, date)
    end

    # Deletes the data for a master instance of TokyoTyrant.
    def delete_master_data(date)
      format = default_master_server_arguments(nil, date)[:format]
      delete_data(:master, date, format)
    end

    # Creates an upstart script for running a slave instance of TokyoTyrant.
    def create_slave_launch_script(master_host, master_port, slave_port, date, options = {})
      options = extract_slave_instance_options(options)
      arguments = default_slave_server_arguments(master_host, master_port, slave_port, date).merge(options)
      create_upstart_script(:slave, date, arguments)
    end

    # Deletes an upstart script for a slave instance of TokyoTyrant.
    def delete_slave_launch_script(date)
      delete_upstart_script(:slave, date)
    end

    # Deletes the data for a slave instance of TokyoTyrant.
    def delete_slave_data(date)
      format = default_slave_server_arguments(nil, nil, nil, date)[:format]
      delete_data(:slave, date, format)
    end

    # If a master server is running to store data for 2 months prior to the
    # given date, its configuration is modified to use less memory and it is
    # restarted.
    def reduce_old_master_server_memory(date, options = {})
      date -= 2.months
      port = master_port_for_date(date)

      if File.exists?(upstart_script_filename(:master, date)) && server_running_on_port?(port)
        options = extract_old_master_instance_options(options)
        arguments = default_old_master_server_arguments(port, date).merge(options)
        create_upstart_script(:master, date, arguments)

        restart_server(:master, date)
      end
    end

    # If a slave server is running to store data for 2 months prior to the
    # given date, its configuration is modified to use less memory and it is
    # restarted.
    def reduce_old_slave_server_memory(master_host, date, options = {})
      date -= 2.months
      master_port = master_port_for_date(date)
      slave_port = slave_port_for_date(date)

      if File.exists?(upstart_script_filename(:slave, date)) && server_running_on_port?(slave_port)
        options = extract_old_slave_instance_options(options)
        arguments = default_old_slave_server_arguments(master_host, master_port, slave_port, date).merge(options)
        create_upstart_script(:slave, date, arguments)

        restart_server(:slave, date)
      end
    end

    # Starts the server using upstart.
    def start_server(type, date)
      Shell.execute "start #{upstart_script_filename(type, date).gsub(/^#{script_directory}\//, '').gsub(/\.conf$/, '')}"
    end

    # Stops the server using upstart.
    def stop_server(type, date)
      Shell.execute "stop #{upstart_script_filename(type, date).gsub(/^#{script_directory}\//, '').gsub(/\.conf$/, '')}"
    end

    # Gets the directory used for storing log files for TokyoTyrant.
    def log_directory
      '/var/log/tokyotyrant'
    end

    # Gets the directory used to store the upstart scripts for TokyoTyrant.
    def script_directory
      '/etc/init'
    end

    private

    # Gets the name of the upstart script for a date.
    def upstart_script_filename(type, date)
      "#{script_directory}/ttserver-#{type}-#{date.strftime('%Y%m')}.conf"
    end

    # Gets the default arguments used to start a master instance of TokyoTyrant.
    def default_master_server_arguments(port, date)
      {
        :sid => '1',
        :thnum => '16',
        :format => 'tch',
        :bnum => '503316469',
        :apow => '11',
        :fpow => '18',
        :ncnum => '6000000',
        :xmsiz => '1073741824',
        :opts => 'lb',
        :slave => false,
        :date => date.strftime('%Y%m'),
        :port => port
      }
    end

    # Gets the default arguments used to start an old master instance of TokyoTyrant.
    def default_old_master_server_arguments(port, date)
      default_master_server_arguments(port, date).merge(:xmsiz => '268435456')
    end

    # Gets the default arguments used to start a slave instance of TokyoTyrant.
    def default_slave_server_arguments(master_host, master_port, slave_port, date)
      {
        :sid => '2',
        :thnum => '24',
        :mhost => master_host,
        :mport => master_port,
        :format => 'tch',
        :bnum => '503316469',
        :apow => '11',
        :fpow => '18',
        :ncnum => '3000000',
        :xmsiz => '536870912',
        :opts => 'lb',
        :slave => true,
        :date => date.strftime('%Y%m'),
        :port => slave_port
      }
    end

    # Gets the default arguments used to start an old slave instance of TokyoTyrant.
    def default_old_slave_server_arguments(master_host, master_port, slave_port, date)
      default_slave_server_arguments(master_host, master_port, slave_port, date).merge(:xmsiz => '134217728')
    end

    # Creates the upstart script to run an instance of TokyoTyrant for a date.
    def create_upstart_script(type, date, arguments)
      filename = upstart_script_filename(type, date)
      template = File.read(File.expand_path('../../templates/upstart.conf.erb', __FILE__))
      erb = ERB.new(template)

      @template_arguments = arguments

      File.open(filename, 'w') { |file| file.write(erb.result(binding)) }
      FileUtils.ln_s '/lib/init/upstart-job', "/etc/init.d/#{File.basename(filename)}"
    end

    # Deletes the upstart script for running an instance of TokyoTyrant for a date.
    def delete_upstart_script(type, date)
      File.delete(upstart_script_filename(type, date))
    end

    # Deletes the data file for an instance of TokyoTyrant for a date.
    def delete_data(type, date, format)
      File.delete("#{data_directory}/ssdata-#{type}-#{date.strftime('%Y%m')}.#{format}")
    end

    # Restarts the server using upstart.
    def restart_server(type, date)
      stop_server(type, date)
      start_server(type, date)
    end

    # Extracts options for master TokyoTyrant instances from an options hash.
    def extract_master_instance_options(options)
      extract_instance_options('master-', options)
    end

    # Extracts options for old master TokyoTyrant instances from an options hash.
    def extract_old_master_instance_options(options)
      extract_instance_options('master-', options).merge(extract_instance_options('old-master-', options))
    end

    # Extracts options for slave TokyoTyrant instances from an options hash.
    def extract_slave_instance_options(options)
      extract_instance_options('slave-', options)
    end

    # Extracts options for old slave TokyoTyrant instances from an options hash.
    def extract_old_slave_instance_options(options)
      extract_instance_options('slave-', options).merge(extract_instance_options('old-slave-', options))
    end

    # Extracts options for TokyoTyrant instances from an options hash.
    def extract_instance_options(prefix, options)
      acceptable_keys = ['sid', 'thnum', 'bnum', 'apow', 'fpow', 'ncnum', 'xmsiz', 'opts']
      keys = options.keys.select { |key| key.to_s.starts_with? prefix }

      keys.inject({}) do |hash, key|
        real_key = key.to_s.gsub(/^#{prefix}/, '')
        hash[real_key.to_sym] = options[key] if acceptable_keys.include? real_key
        hash
      end
    end
  end
end
