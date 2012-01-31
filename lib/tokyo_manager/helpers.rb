module TokyoManager
  module Helpers
    MASTER_BASE_PORT = 10000
    SLAVE_BASE_PORT = 12000

    EPOCH_YEAR = Time.at(0).year
    EPOCH_MONTH = Time.at(0).month

    def master_port_for_date(date)
      months_since_epoch(date) + MASTER_BASE_PORT
    end

    def slave_port_for_date(date)
      months_since_epoch(date) + SLAVE_BASE_PORT
    end

    def linux?
      !darwin?
    end

    def darwin?
      RUBY_PLATFORM =~ /darwin/
    end

    private

    def months_since_epoch(date)
      ((EPOCH_YEAR - date.year).abs * 12) + (EPOCH_MONTH - date.month).abs
    end
  end
end
