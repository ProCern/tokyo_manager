module TokyoManager
  # Provides methods for managing instances of TokyoTyrant running on Mac OS X.
  module DarwinInstanceManagement
    # Creates a launchd script for running a master instance of TokyoTyrant.
    def create_master_launch_script(port, date)
      create_launchd_script(port, date)
    end

    # Creates a launchd script for running a slave instance of TokyoTyrant.
    # This is not supported on Mac OS X.
    def create_slave_launch_script(master_host, master_port, slave_port, date)
      raise 'Slave instances are only supported on Linux'
    end

    # Starts the server using launchd.
    def start_server(type, date)
      if type == :master
        Shell.execute "launchctl load -w #{launchd_script_filename(date)}"
      end
    end

    # Stops the server using upstart.
    def stop_server(type, date)
      if type == :master
        Shell.execute "launchctl unload -w #{launchd_script_filename(date)}"
      end
    end

    # Gets the directory used for storing data files for TokyoTyrant.
    def data_directory
      '/usr/local/var/tokyo-tyrant'
    end

    # Gets the directory used for storing log files for TokyoTyrant.
    def log_directory
      '/usr/local/var/log/tokyo-tyrant'
    end

    # Gets the directory used to store the launchd scripts for TokyoTyrant.
    def script_directory
      "#{ENV['HOME']}/Library/LaunchAgents"
    end

    private

    # Gets the name of the launchd script for a date.
    def launchd_script_filename(date)
      "#{script_directory}/org.tokyotyrant.ttserver-#{date.strftime('%Y%m')}.plist"
    end

    # Creates the launchd script to run an instance of TokyoTyrant for a date.
    def create_launchd_script(port, date)
      template = File.read(File.expand_path('../../templates/launchd.plist.erb', __FILE__))
      erb = ERB.new(template)

      @template_arguments = { :port => port, :date => date }

      File.open(launchd_script_filename(date), 'w') do |file|
        file.write(erb.result(binding))
      end
    end
  end
end
