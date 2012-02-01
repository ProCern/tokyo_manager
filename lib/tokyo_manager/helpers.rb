module TokyoManager
  module Helpers
    MASTER_BASE_PORT = 10000
    SLAVE_BASE_PORT = 12000

    EPOCH_YEAR = 1970
    EPOCH_MONTH = 1

    # Gets the port for running a master instance of TokyoTyrant for a date.
    def master_port_for_date(date)
      months_since_epoch(date) + MASTER_BASE_PORT
    end

    # Gets the port for running a slave instance of TokyoTyrant for a date.
    def slave_port_for_date(date)
      months_since_epoch(date) + SLAVE_BASE_PORT
    end

    # Determines if we are running on Linux.
    def linux?
      !darwin?
    end

    # Determines if we are running on Mac OS X.
    def darwin?
      platform =~ /darwin/
    end

    private

    # Gets the platform we are running on.
    def platform
      RUBY_PLATFORM
    end

    # Determines the number of months between the epoch date (Januare 1, 1970)
    # and the given date.
    def months_since_epoch(date)
      ((EPOCH_YEAR - date.year).abs * 12) + (EPOCH_MONTH - date.month).abs
    end
  end
end
