module TokyoManager
  module InstanceManager
    def start_master_for_date(date)

    end

    def start_slave_for_date(date)

    end

    private

    def data_directory
      if linux?
        '/data/tokyotyrant/'
      else
        '/usr/local/var/tokyo-tyrant/'
    end

    def log_directory
      if linux?
        '/var/log/tokyotyrant/'
      else
        '/usr/local/var/log/tokyo-tyrant/'
      end
    end

    def current_master_arguments(date)
      # formatted_date = date.strftime('%Y%m')
      # {
      #   :port => port_for_date(date),
      #   :log_file => "#{log_directory}ttserver-#{formatted_date}.log",
      #   :ulog_file => "#{data_directory}ttserver_ulog-#{formatted_date}",
      #   :ulim => '16777216',
      #   :sid => '1',
      #   :thnum => '8',
      #   :loglevel => '-le',
      #   :data_dir => data_directory,
      #   :name => 'ttserver',
      #   :format => 'tcb',
      #   :bnum => '4000000',
      #   :lcnum => '40960',
      #   :xmsiz => '536870912',
      #   :opts => 'lb'
      # }
    end

    def prior_master_arguments(date)
      # formatted_date = date.strftime('%Y%m')
      # {
      #   :port => port_for_date(date),
      #   :log_file => "#{log_directory}ttserver-#{formatted_date}.log",
      #   :ulog_file => "#{data_directory}ttserver_ulog-#{formatted_date}",
      #   :ulim => '16777216',
      #   :sid => '1',
      #   :thnum => '8',
      #   :loglevel => '-le',
      #   :data_dir => data_directory,
      #   :name => 'ttserver',
      #   :format => 'tcb',
      #   :bnum => '4000000',
      #   :lcnum => '40960',
      #   :xmsiz => '536870912',
      #   :opts => 'lb'
      # }
    end

    def master_arguments(arguments)
      # server_arguments = "-port #{arguments[:port]} "
      # server_arguments << "-log #{arguments[:log_file]} "
      # server_arguments << "-ulog #{arguments[:ulog_file]} "
      # server_arguments << "-ulim #{arguments[:ulim]} "
      # server_arguments << "-sid #{arguments[:sid]} "
      # server_arguments << "-thnum #{arguments[:thnum]} "
      # server_arguments << "#{arguments[:logleve]} "
      # server_arguments << "#{arguments[:data_dir]}/#{arguments[:name]}.#{arguments[:format]}"
      # server_arguments << "#bnum=#{arguments[:bnum]}"
      # server_arguments << "#lcnum=#{arguments[:lcnum]}"
      # server_arguments << "#xmsiz=#{arguments[:xmsiz]}"
      # server_arguments << "#opts=#{arguments[:opts]}"
      # server_arguments
    end
  end
end
