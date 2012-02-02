module TokyoManager
  # Gets a connection to the TokyoTyrant instance running for a given date from
  # the ConnectionManager. If a block is given the connection is yielded.
  # Otherwise, the connection is returned.
  #
  # Example usage:
  #
  #     TokyoManager.connection_for_date(Date.new(2012, 2, 1)) do |connection|
  #       # do something with the connection
  #     end
  def self.connection_for_date(date)
    @connection_manager ||= ConnectionManager.new
    connection = @connection_manager.connection_for_date(date)

    if block_given?
      yield connection
    else
      connection
    end
  end

  def self.clear_connections!
    if @connection_manager
      @connection_manager.connections.each_value do |connection|
        connection.close if connection.respond_to?(:close)
      end

      @connection_manager.connections.clear
    end
  end

  # Provides methods for getting connections to TokyoTyrant instances based on a date.
  class ConnectionManager
    include TokyoManager::Helpers

    attr_reader :connections

    def initialize
      @connections = {}
    end

    # Gets a connection to the TokyoTyrant instance running for a given date.
    # The instance is found by determining the port number based on the date.
    # The port number is the number of months between the epoch date and the
    # given date, plus 10,000.
    #
    # If no instance is running for the date, the default port is used to
    # connect to the legacy database that was used prior to using the
    # TokyoManager.
    #
    # Connections are stored in a hash that allows the connections to be
    # reused. This was done because when opening and closing a lot of
    # connections very rapidly, errors started happening in the
    # ruby-tokyotyrant gem or the underlying tokyotyrant library.
    def connection_for_date(date)
      host = TokyoManager.configuration.host
      port = master_port_for_date(date)
      connection_key = "#{host}:#{port}"

      if connection = connections[connection_key]
        return connection
      end

      begin
        connection = TokyoTyrant::DB.new(host, port)
      rescue TokyoTyrantErrorRefused
        begin
          # if no database exists for the given date, fall back to the legacy database on the default port
          default_port = TokyoManager.configuration.default_port
          connection = TokyoTyrant::DB.new(host, default_port)
          connections["#{host}:#{default_port}"] = connection
        rescue TokyoTyrantErrorRefused
          connection = nil
        end
      end

      unless connection
        raise "Failed to connect to TokyoTyrant at #{host}:#{port}"
      end

      connections[connection_key] = connection
      connection
    end
  end
end
