# Installation

To use tokyo-manager as part of your Rails application, include this line in
your Gemfile:

    gem 'tokyo-manager', :git => 'git://github.com/absperf/tokyo-manager.git'

To install the executable on your system, execute:

    git clone git://github.com/absperf/tokyo-manager.git
    cd tokyo-manager
    bundle
    bundle exec rake install

# Usage

## Starting New Instances

To start a new master instance of TokyoTyrant for next month:

    tokyo-manager start --master

To start a new slave instance of TokyoTyrant for next month:

    tokyo-manager start --slave

To specify the month to start the instance for:

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
