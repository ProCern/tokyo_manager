# Summary

This library is used to manage instances of TokyoTyrant that store observation
data for the System Shepherd backend. New instances of TokyoTyrant should be
created each month to store the data for the next month. See the 'Starting New
Instances' section for more information.

Each instance is assigned a port based on its type and the month that it is
going to be storing data for. The base port for master instances is 10,000 and
12,000 for slave instances. The number of months between the epoch date
(January 1, 1970) and the given (or current) date is then added to the base
port to get the port to run the instance on.

This library can also be used to manage connections to TokyoTyrant instances
based on a date. See the 'Connecting To Instances' section for more
information.

# Installation

To use tokyo_manager as part of your Rails application, include this line in
your Gemfile:

    gem 'tokyo_manager', :git => 'git://github.com/absperf/tokyo_manager.git'

To install the executable on your system, execute:

    git clone git://github.com/absperf/tokyo_manager.git
    cd tokyo_manager
    bundle
    bundle exec rake install

# Usage

## Starting New Instances

To start a new master instance of TokyoTyrant for next month:

    tokyo-manager start --master

To start a new slave instance of TokyoTyrant for next month:

    tokyo-manager start --slave

When starting a new slave, if the master is on a different host than the slave, provide the host for the master:

    tokyo-manager start --slave --host tt.ssbe.api

To specify the month to start the instance for, give the date in YYYYMM format:

    tokyo-manager start --master --date 201201

or

    tokyo-manager start --slave --date 201201

## Connecting To Instances

Inside of your application, get a connection to the correct TokyoTyrant
instance by calling:

    TokyoManager.connection_for_date(date)

If an instance is running for the specified date, a connection to that instance
will be returned. Otherwise, a connection to the instance running on the default
port will be returned. If no connection can be established, an error will be
raised.

This method will yeild the connection to a block if given. Otherwise, the
connection is returned.

    TokyoManager.connection_for_date(date) do |connection|
      # do something with the connection
    end

    connection = TokyoManager.connection_for_date(date)
    # do something with the connection
