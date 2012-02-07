require 'spec_helper'

describe TokyoManager::ConnectionManager do
  let(:date) { Date.new(2012, 1, 31) }

  before do
    TokyoManager.clear_connections!
  end

  describe "connection_for_date" do
    context "when an instance is running for the date" do
      let(:connection) { Object.new }

      before do
        TokyoTyrant::DB.should_receive(:new).with('localhost', 10504, 0.0, true).and_return(connection)
      end

      it "returns a connection to the instance" do
        TokyoManager.connection_for_date(date).should be(connection)
      end
    end

    context "when an instance is not running for the date" do
      context "when an instance is running on the default port" do
        let(:connection) { Object.new }

        before do
          TokyoTyrant::DB.should_receive(:new).with('localhost', 10504, 0.0, true).and_raise(TokyoTyrantErrorRefused)
          TokyoTyrant::DB.should_receive(:new).with('localhost', 1978, 0.0, true).and_return(connection)
        end

        it "returns a connection to the default instance" do
          TokyoManager.connection_for_date(date).should be(connection)
        end
      end

      context "when an instance is not running on the default port" do
        before do
          TokyoTyrant::DB.should_receive(:new).with('localhost', 10504, 0.0, true).and_raise(TokyoTyrantErrorRefused)
          TokyoTyrant::DB.should_receive(:new).with('localhost', 1978, 0.0, true).and_raise(TokyoTyrantErrorRefused)
        end

        it "raises an error" do
          lambda { TokyoManager.connection_for_date(date) }.should raise_error('Failed to connect to TokyoTyrant at localhost:10504')
        end
      end
    end
  end
end
