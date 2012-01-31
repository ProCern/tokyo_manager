module TokyoManager
  module DarwinInstanceManagement
    def create_master_launch_script(port, date)
      create_launchd_script(port, date)
    end

    def create_slave_launch_script(master_port, slave_port, date)
      raise 'Slave instances are only supported on Linux'
    end

    def start_server(type, date)
      `launchctl load -w #{launchd_script_filename(date)}`
    end

    def stop_server(type, date)
      `launchctl unload -w #{launchd_script_filename(date)}`
    end

    def data_directory
      '/usr/local/var/tokyo-tyrant'
    end

    def log_directory
      '/usr/local/var/log/tokyo-tyrant'
    end

    private

    def launchd_script_filename(date)
      "#{ENV['HOME']}/Library/LaunchAgents/org.tokyotyrant.ttserver-#{date.strftime('%Y%m')}.plist"
    end

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
