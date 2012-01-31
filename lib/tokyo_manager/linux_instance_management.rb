module TokyoManager
  module LinuxInstanceManagement
    def create_master_launch_script(port, date)
      arguments = default_master_server_arguments(port, date)
      create_upstart_script(:master, date, arguments)
    end

    def create_slave_launch_script(master_port, slave_port, date)
      arguments = default_master_server_arguments(port, date).merge(:xmsiz => '268435456')
      create_upstart_script(:slave, date, arguments)
    end

    def reduce_old_master_server_memory(date)
      date -= 2.months
      port = master_port_for_date(date)

      if server_running_on_port?(port) && File.exists?(upstart_script_filename(:master, date))
        arguments = default_master_server_arguments(port, date).merge(:xmsiz => '268435456')
        create_upstart_script(:master, date, arguments)

        restart_server(date)
      end
    end

    def reduce_old_slave_server_memory(date)
      date -= 2.months
      master_port = master_port_for_date(date)
      slave_port = slave_port_for_date(date)

      if server_running_on_port?(port) && File.exists?(upstart_script_filename(:slave, date))
        arguments = default_slave_server_arguments(port, date).merge(:xmsiz => '134217728')
        create_upstart_script(:slave, date, arguments)

        restart_server(date)
      end
    end

    def start_server(type, date)
      `start #{upstart_script_filename(type, date)}`
    end

    def stop_server(type, date)
      `stop #{upstart_script_filename(type, date)}`
    end

    def data_directory
      '/data/tokyotyrant'
    end

    def log_directory
      '/var/log/tokyotyrant'
    end

    private

    def upstart_script_filename(type, date)
      "/etc/init/ttserver-#{type}-#{date.strftime('%Y%m')}.conf"
    end

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

    def default_slave_server_arguments(master_port, slave_port, date)
      {
        :sid => '2',
        :thnum => '24',
        :mhost => 'tt.ssbe.api',
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

    def create_upstart_script(type, date, arguments)
      template = File.read(File.expand_path('../../templates/upstart.conf.erb', __FILE__))
      erb = ERB.new(template)

      @template_arguments = arguments

      File.open(upstart_script_filename(type, date), 'w') do |file|
        file.write(erb.result(binding))
      end
    end

    def restart_server(type, date)
      stop_server(type, date)
      start_server(type, date)
    end
  end
end
