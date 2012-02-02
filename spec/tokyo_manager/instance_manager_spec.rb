require 'spec_helper'

describe "TokyoManager::InstanceManager" do
  subject do
    TokyoManager::InstanceManager.new
  end

  describe "start_master_for_date" do
    context "when the server is already running" do
      before do
        subject.stub(:server_running_on_port?).and_return(true)
      end

      it "raises an error" do
        lambda { subject.start_master_for_date(Date.new(2012, 2, 1)) }.should raise_error('Server is already running for 02/2012 on port 10505')
      end
    end

    context "when the server is not running" do
      before do
        subject.stub(:server_running_on_port?).and_return(false)
      end

      it "creates the launch script, starts, the server, and reduces the old server's memory usage" do
        subject.should_receive(:create_master_launch_script)
        subject.should_receive(:start_server)
        subject.should_receive(:reduce_old_master_server_memory)
        subject.start_master_for_date(Date.new(2012, 2, 1))
      end
    end
  end

  describe "start_slave_for_date" do
    context "when the server is already running" do
      before do
        subject.stub(:server_running_on_port?).and_return(true)
      end

      it "raises an error" do
        lambda { subject.start_slave_for_date(Date.new(2012, 2, 1), 'tt.ssbe.api') }.should raise_error('Server is already running for 02/2012 on port 12505')
      end
    end

    context "when the server is not running" do
      before do
        subject.stub(:server_running_on_port?).and_return(false)
      end

      it "creates the launch script, starts, the server, and reduces the old server's memory usage" do
        subject.should_receive(:create_slave_launch_script)
        subject.should_receive(:start_server)
        subject.should_receive(:reduce_old_slave_server_memory)
        subject.start_slave_for_date(Date.new(2012, 2, 1), 'tt.ssbe.api')
      end
    end
  end

  describe "delete_master_for_date" do
    context "when the server is not running" do
      before do
        subject.stub(:server_running_on_port?).and_return(false)
      end

      it "raises an error" do
        lambda { subject.delete_master_for_date(Date.new(2012, 2, 1)) }.should raise_error('Server is not running for 02/2012 on port 10505')
      end
    end

    context "when the server is running" do
      before do
        subject.stub(:server_running_on_port?).and_return(true)
      end

      it "stops the server, deletes the launch script, and deletes the data" do
        subject.should_receive(:stop_server)
        subject.should_receive(:delete_master_launch_script)
        subject.should_receive(:delete_master_data)
        subject.delete_master_for_date(Date.new(2012, 2, 1))
      end
    end
  end

  describe "delete_slave_for_date" do
    context "when the server is not running" do
      before do
        subject.stub(:server_running_on_port?).and_return(false)
      end

      it "raises an error" do
        lambda { subject.delete_slave_for_date(Date.new(2012, 2, 1)) }.should raise_error('Server is not running for 02/2012 on port 12505')
      end
    end

    context "when the server is running" do
      before do
        subject.stub(:server_running_on_port?).and_return(true)
      end

      it "stops the server, deletes the launch script, and deletes the data" do
        subject.should_receive(:stop_server)
        subject.should_receive(:delete_slave_launch_script)
        subject.should_receive(:delete_slave_data)
        subject.delete_slave_for_date(Date.new(2012, 2, 1))
      end
    end
  end
end
