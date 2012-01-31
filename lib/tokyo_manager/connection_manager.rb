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
        begin
          # if no database exists for the given date, fall back to the legacy database on the default port
          connection = TokyoTyrant::DB.new(host, default_port)
        rescue TokyoTyrantErrorRefused
          connection = nil
        end
      end

      unless connection
        raise "Failed to connect to TokyoTyrant at #{host}:#{port}"
      end

      connection
    end
  end
end
