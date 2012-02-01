module TokyoManager
  # Gets a connection to the TokyoTyrant instance running for a given date from
  # the ConnectionManager. If a block is given the connection is yielded and
  # closed after the block is executed. Otherwise, the connection is returned.
  #
  # Example usage:
  #
  #     TokyoManager.connection_for_date(Date.new(2012, 2, 1)) do |connection|
  #       # do something with the connection
  #     end
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

  # Provides methods for getting connections to TokyoTyrant instances based on a date.
  class ConnectionManager
    include TokyoManager::Configuration
    include TokyoManager::Helpers

    # Gets a connection to the TokyoTyrant instance running for a given date.
    # The instance is found by determining the port number based on the date.
    # The port number is the number of months between the epoch date and the
    # given date, plus 10,000.
    #
    # If no instance is running for the date, the default port is used to
    # connect to the legacy database that was used prior to using the
    # TokyoManager.
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
