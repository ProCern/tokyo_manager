require 'spec_helper'
require 'fileutils'

describe TokyoManager::LinuxInstanceManagement do
  subject do
    Object.new.tap do |object|
      object.extend TokyoManager::Helpers
      object.extend TokyoManager::LinuxInstanceManagement
    end
  end

  describe "create_master_launch_script" do
    let(:file_path) { File.expand_path('../../../tmp/ttserver-master-201202.conf', __FILE__) }

    before do
      subject.stub(:script_directory).and_return(File.expand_path('../../../tmp', __FILE__))
      File.delete(file_path) if File.exists?(file_path)
    end

    it "creates an upstart script" do
      subject.create_master_launch_script(12345, Date.new(2012, 2, 1))

      File.exists?(file_path).should be_true

      contents = File.read(file_path)
      contents.should match(/ssdata-master-201202/)
      contents.should match(/-port 12345/)
    end
  end

  describe "create_slave_launch_script" do
    let(:file_path) { File.expand_path('../../../tmp/ttserver-slave-201202.conf', __FILE__) }

    before do
      subject.stub(:script_directory).and_return(File.expand_path('../../../tmp', __FILE__))
      File.delete(file_path) if File.exists?(file_path)
    end

    it "creates an upstart script" do
      subject.create_slave_launch_script(12345, 23456, Date.new(2012, 2, 1))

      File.exists?(file_path).should be_true

      contents = File.read(file_path)
      contents.should match(/ssdata-slave-201202/)
      contents.should match(/-port 23456/)
      contents.should match(/-mport 12345/)
    end
  end

  describe "reduce_old_master_server_memory" do
    let(:file_path) { File.expand_path('../../../tmp/ttserver-master-201112.conf', __FILE__) }

    before do
      File.delete(file_path) if File.exists?(file_path)
      subject.stub(:script_directory).and_return(File.expand_path('../../../tmp', __FILE__))
    end

    context "when the old server is not running" do
      it "does nothing" do
        subject.should_not_receive(:create_upstart_script)
        subject.should_not_receive(:restart_server)
        subject.reduce_old_master_server_memory(Date.new(2012, 2, 1))
      end
    end

    context "when the old server is running" do
      before do
        FileUtils.touch file_path
        subject.should_receive(:server_running_on_port?).with(10504).and_return(true)
        subject.should_receive(:stop_server).with(:master, Date.new(2011, 12, 1))
        subject.should_receive(:start_server).with(:master, Date.new(2011, 12, 1))
      end

      it "reduces its memory usage" do
        subject.reduce_old_master_server_memory(Date.new(2012, 2, 1))

        File.exists?(file_path).should be_true

        contents = File.read(file_path)
        contents.should match(/ssdata-master-201112/)
        contents.should match(/-port 10504/)
        contents.should match(/xmsiz=268435456/)
      end
    end
  end

  describe "reduce_old_slave_server_memory" do
    let(:file_path) { File.expand_path('../../../tmp/ttserver-slave-201112.conf', __FILE__) }

    before do
      File.delete(file_path) if File.exists?(file_path)
      subject.stub(:script_directory).and_return(File.expand_path('../../../tmp', __FILE__))
    end

    context "when the old server is not running" do
      it "does nothing" do
        subject.should_not_receive(:create_upstart_script)
        subject.should_not_receive(:restart_server)
        subject.reduce_old_slave_server_memory(Date.new(2012, 2, 1))
      end
    end

    context "when the old server is running" do
      before do
        FileUtils.touch file_path
        subject.should_receive(:server_running_on_port?).with(12504).and_return(true)
        subject.should_receive(:stop_server).with(:slave, Date.new(2011, 12, 1))
        subject.should_receive(:start_server).with(:slave, Date.new(2011, 12, 1))
      end

      it "reduces its memory usage" do
        subject.reduce_old_slave_server_memory(Date.new(2012, 2, 1))

        File.exists?(file_path).should be_true

        contents = File.read(file_path)
        contents.should match(/ssdata-slave-201112/)
        contents.should match(/-port 12504/)
        contents.should match(/-mport 10504/)
        contents.should match(/xmsiz=134217728/)
      end
    end
  end

  describe "start_server" do
    context "with a master instance" do
      it "starts the server" do
        TokyoManager::Shell.should_receive(:execute).with('start ttserver-master-201202')
        subject.start_server(:master, Date.new(2012, 2, 1))
      end
    end

    context "with a slave instance" do
      it "starts the server" do
        TokyoManager::Shell.should_receive(:execute).with('start ttserver-slave-201202')
        subject.start_server(:slave, Date.new(2012, 2, 1))
      end
    end
  end

  describe "stop_server" do
    context "with a master instance" do
      it "stops the server" do
        TokyoManager::Shell.should_receive(:execute).with('stop ttserver-master-201202')
        subject.stop_server(:master, Date.new(2012, 2, 1))
      end
    end

    context "with a slave instance" do
      it "stops the server" do
        TokyoManager::Shell.should_receive(:execute).with('stop ttserver-slave-201202')
        subject.stop_server(:slave, Date.new(2012, 2, 1))
      end
    end
  end

  describe "data_directory" do
    it "returns the data directory" do
      subject.data_directory.should eq('/data/tokyotyrant')
    end
  end

  describe "log_directory" do
    it "returns the log directory" do
      subject.log_directory.should eq('/var/log/tokyotyrant')
    end
  end
end
