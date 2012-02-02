require 'spec_helper'

describe TokyoManager::DarwinInstanceManagement do
  subject do
    Object.new.tap do |object|
      object.extend TokyoManager::DarwinInstanceManagement
    end
  end

  describe "create_master_launch_script" do
    it "creates a launchd script" do
      subject.stub(:script_directory).and_return(File.expand_path('../../../tmp', __FILE__))
      subject.create_master_launch_script(12345, Date.new(2012, 2, 1))

      file_path = File.expand_path('../../../tmp/org.tokyotyrant.ttserver-201202.plist', __FILE__)
      File.exists?(file_path).should be_true

      contents = File.read(file_path)
      contents.should match(/<string>org.tokyotyrant.ttserver-201202<\/string>/)
      contents.should match(/<string>12345<\/string>/)
    end
  end

  describe "delete_master_launch_script" do
    it "deletes a launch script" do
      subject.stub(:script_directory).and_return(File.expand_path('../../../tmp', __FILE__))

      file_path = File.expand_path('../../../tmp/org.tokyotyrant.ttserver-201202.plist', __FILE__)
      File.open(file_path, 'w') { |file| file.write('test') }

      subject.delete_master_launch_script(Date.new(2012, 2, 1))

      File.exists?(file_path).should be_false
    end
  end

  describe "delete_master_data" do
    it "deletes the database file" do
      subject.stub(:data_directory).and_return(File.expand_path('../../../tmp', __FILE__))

      file_path = File.expand_path('../../../tmp/db-201202.tch', __FILE__)
      File.open(file_path, 'w') { |file| file.write('test') }

      subject.delete_master_data(Date.new(2012, 2, 1))

      File.exists?(file_path).should be_false
    end
  end

  describe "create_slave_launch_script" do
    it "is not supported" do
      lambda { subject.create_slave_launch_script('tt.ssbe.api', 12345, 23456, Date.today) }.should raise_error('Slave instances are only supported on Linux')
    end
  end

  describe "delete_slave_launch_script" do
    it "is not supported" do
      lambda { subject.delete_slave_launch_script(Date.today) }.should raise_error('Slave instances are only supported on Linux')
    end
  end

  describe "delete_slave_data" do
    it "is not supported" do
      lambda { subject.delete_slave_data(Date.today) }.should raise_error('Slave instances are only supported on Linux')
    end
  end

  describe "start_server" do
    context "with a master instance" do
      it "starts the server" do
        subject.stub(:script_directory).and_return('/tmp')
        TokyoManager::Shell.should_receive(:execute).with("launchctl load -w /tmp/org.tokyotyrant.ttserver-201202.plist").and_return(nil)

        subject.start_server(:master, Date.new(2012, 2, 1))
      end
    end

    context "with a slave instance" do
      it "does nothing" do
        TokyoManager::Shell.should_not_receive(:execute)
        subject.start_server(:slave, Date.new(2012, 2, 1))
      end
    end
  end

  describe "stop_server" do
    context "with a master instance" do
      it "stops the server" do
        subject.stub(:script_directory).and_return('/tmp')
        TokyoManager::Shell.should_receive(:execute).with("launchctl unload -w /tmp/org.tokyotyrant.ttserver-201202.plist").and_return(nil)

        subject.stop_server(:master, Date.new(2012, 2, 1))
      end
    end

    context "with a slave instance" do
      it "does nothing" do
        TokyoManager::Shell.should_not_receive(:execute)
        subject.stop_server(:slave, Date.new(2012, 2, 1))
      end
    end
  end

  describe "data_directory" do
    it "returns the data directory" do
      subject.data_directory.should eq('/usr/local/var/tokyo-tyrant')
    end
  end

  describe "log_directory" do
    it "returns the log directory" do
      subject.log_directory.should eq('/usr/local/var/log/tokyo-tyrant')
    end
  end

  describe "script_directory" do
    it "returns the script directory" do
      ENV['HOME'] = '/tmp'
      subject.script_directory.should eq('/tmp/Library/LaunchAgents')
    end
  end
end
