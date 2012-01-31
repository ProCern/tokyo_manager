module TokyoManager
  def self.connection_for_date(date)
    connection = ConnectionManager.new.connection_for_date(date)

    if block_given?
      begin
        yield connection
      ensure
        connection.close
      end
    else
      connection
    end
  end

  class ConnectionManager
    include TokyoManager::Configuration
    include TokyoManager::Helpers

    def connection_for_date(date)
      port = master_port_for_date(date)

      begin
        connection = TokyoTyrant::DB.new(host, port)
      rescue TokyoTyrantErrorRefused
        # if no database exists for the given date, fall back to the legacy database on the default port
        connection = TokyoTyrant::DB.new(host, default_port)
      end

      unless connection
        raise "Failed to connect to TokyoTyrant at #{host}:#{port} - #{connection.errmsg(connection.ecode)}"
      end

      connection
    end
  end
end
