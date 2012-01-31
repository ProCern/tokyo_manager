module TokyoManager
  module Helpers
    BASE_PORT = 10000

    EPOCH_YEAR = Time.at(0).year
    EPOCH_MONTH = Time.at(0).month

    def port_for_date(date)
      months_since_epoch(date) + BASE_PORT
    end

    def linux?
      !osx?
    end

    def osx?
      RUBY_PLATFORM =~ /darwin/
    end

    private

    def months_since_epoch(date)
      ((EPOCH_YEAR - date.year).abs * 12) + (EPOCH_MONTH - date.month).abs
    end
  end
end
